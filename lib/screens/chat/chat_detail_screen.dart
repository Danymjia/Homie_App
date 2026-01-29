import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/services/apartment_service.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';
import 'package:roomie_app/services/chat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:io';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/theme_provider.dart';
import 'package:roomie_app/models/apartment_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService _chatService = ChatService();
  final ApartmentService _apartmentService = ApartmentService();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? _otherUserProfile;
  ApartmentModel? _apartment;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadChatMetadata();
  }

  Future<void> _loadChatMetadata() async {
    // 1. Get other user info
    final metadata = await _chatService.getChatMetadata(widget.chatId);

    // 2. Get apartment info from chat
    ApartmentModel? apartment;
    try {
      final chatRes = await _supabase
          .from('chats')
          .select('apartment_id')
          .eq('id', widget.chatId)
          .single();

      final apartmentId = chatRes['apartment_id'];
      if (apartmentId != null) {
        final aptRes = await _supabase
            .from('apartments')
            .select()
            .eq('id', apartmentId)
            .single();
        apartment = ApartmentModel.fromJson(aptRes);
      }
    } catch (e) {
      debugPrint('Error getting apartment info: $e');
    }

    if (mounted) {
      setState(() {
        _otherUserProfile = metadata;
        _apartment = apartment;
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await _chatService.sendMessage(widget.chatId, text);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    }
  }

  Future<void> _handleBeRoomies() async {
    if (_apartment == null) return;

    try {
      // 1. Mark as occupied
      await _apartmentService.markAsOccupied(_apartment!.id);

      // 2. Show dialog
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text('¡Felicidades!',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Es momento de agendar una cita',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFFE5989B))),
            ),
          ],
        ),
      );

      // 3. Send automated message
      final msg = "¡Genial! Me alegra que vayamos a ser roomies.\n"
          "Dirección: ${_apartment!.address}\n"
          "Día y hora a acordar.";

      await _chatService.sendMessage(widget.chatId, msg);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default placeholder if loading or not found
    final otherUserName = _otherUserProfile?['full_name'] ?? 'Usuario';
    final otherUserPhoto = _otherUserProfile?['photo_url'];
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Show button only if I am the owner and apartment exists
    final showRoomiesButton = !_isLoadingProfile &&
        _apartment != null &&
        _apartment!.ownerId == _currentUserId &&
        _apartment!
            .isActive; // Only show if still active? Or always allow? Assuming prompt: change to occupied.

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: _isLoadingProfile
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ProfileAvatar(
                          imageUrl: otherUserPhoto,
                          name: otherUserName,
                          size: 40,
                          borderRadius: 50,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUserName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          if (showRoomiesButton)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ElevatedButton(
                onPressed: _handleBeRoomies,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5989B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Ser roomies',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages Stream
          Expanded(
            child: Container(
              decoration: themeProvider.chatWallpaperPath != null
                  ? BoxDecoration(
                      image: DecorationImage(
                        image:
                            FileImage(File(themeProvider.chatWallpaperPath!)),
                        fit: BoxFit.cover,
                        opacity: themeProvider.chatWallpaperOpacity,
                      ),
                    )
                  : null,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _chatService.getMessagesStream(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.reversed.toList();

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message['sender_id'] == _currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF000000),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF171717),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final time = DateTime.parse(message['created_at']).toLocal();
    final timeString = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isMe ? Theme.of(context).primaryColor : const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message['text'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeString,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
