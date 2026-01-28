import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';
import 'package:roomie_app/services/chat_service.dart';
import 'package:roomie_app/services/match_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roomie_app/screens/match/match_screen.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/theme_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatService _chatService = ChatService();
  final MatchService _matchService = MatchService();
  int _requestsTabIndex = 0; // 0: Received, 1: Sent

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept({
    required String swipeId,
    required String otherUserId,
    required String apartmentId,
    required String otherName,
    required String otherPhotoUrl,
  }) async {
    try {
      final chatId = await _matchService.acceptMatch(
        swipeId: swipeId,
        otherUserId: otherUserId,
        apartmentId: apartmentId,
      );

      // Fetch my profile for the match screen
      final myId = Supabase.instance.client.auth.currentUser!.id;
      final myProfile = await Supabase.instance.client
          .from('profiles')
          .select('photo_url')
          .eq('id', myId)
          .single();

      final myPhotoUrl = myProfile['photo_url'] ?? '';

      if (mounted) {
        setState(() {}); // Refresh list to remove the request

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchScreen(
              chatId: chatId,
              myPhotoUrl: myPhotoUrl,
              otherPhotoUrl: otherPhotoUrl,
              otherName: otherName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      debugPrint('Error accepting match: $e');
    }
  }

  Future<void> _handleReject(String swipeId) async {
    try {
      await _matchService.rejectMatch(swipeId);
      if (mounted) {
        setState(() {}); // Refresh list
      }
    } catch (e) {
      debugPrint('Error rejecting: $e');
    }
  }

  Future<void> _handleCancelSent(String swipeId) async {
    try {
      await _matchService.cancelSentLike(swipeId);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud cancelada')),
        );
      }
    } catch (e) {
      debugPrint('Error cancelling: $e');
    }
  }

  Future<void> _launchHomieHelper() async {
    final Uri url = Uri.parse(
        'https://cdn.botpress.cloud/webchat/v3.5/shareable.html?configUrl=https://files.bpcontent.cloud/2026/01/27/23/20260127232237-CNXBLQW8.json');
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Homie Helper')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme =
        themeProvider.getThemeById(themeProvider.currentThemeId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 24),
          child: Text(
            'Conexiones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: currentTheme['primaryColor'],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Solicitudes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Chats Tab
          _buildChatsList(),
          // 2. Requests Tab
          _buildRequestsList(),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildChatsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _chatService.getConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        }

        final conversations = snapshot.data ?? [];

        // Combine static bot + conversations
        final itemCount = conversations.length + 1; // +1 for Homie Helper

        /* if (conversations.isEmpty) { ... } Removed to always show bot */

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Index 0 is always Homie Helper
            if (index == 0) {
              return _buildHomieHelperItem();
            }

            final chat = conversations[index - 1]; // Offset index
            final profile = chat['profiles'] as Map<String, dynamic>?;
            final name = profile?['full_name'] ?? 'Usuario';
            final photoUrl = profile?['photo_url'];
            final chatId = chat['chat_id'];

            return _buildChatItem(
              context,
              name: name,
              lastMessage: 'Toca para ver mensajes',
              time: '',
              avatar: photoUrl,
              chatId: chatId,
            );
          },
        );
      },
    );
  }

  Widget _buildHomieHelperItem() {
    return InkWell(
      onTap: _launchHomieHelper,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5), // Bot color
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Homie Helper',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tu asistente virtual 24/7',
                    style: TextStyle(
                      color: Color(0xFF1E88E5), // Highlight
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return Column(
      children: [
        // Toggle Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _requestsTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _requestsTabIndex == 0
                            ? const Color(0xFFFF4B63)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'Recibidas',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _requestsTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _requestsTabIndex == 1
                            ? const Color(0xFFFF4B63)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'Enviadas',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // List Content
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _requestsTabIndex == 0
                ? _matchService.getIncomingLikes()
                : _matchService.getSentLikes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          _requestsTabIndex == 0
                              ? Icons.favorite_border
                              : Icons.send_rounded,
                          size: 48,
                          color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _requestsTabIndex == 0
                            ? 'No tienes solicitudes nuevas.'
                            : 'No has enviado solicitudes aún.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final profile = req['profiles'] as Map<String, dynamic>?;
                  final apt = req['apartments'] as Map<String, dynamic>?;

                  final name = profile?['full_name'] ?? 'Usuario';
                  final photoUrl = profile?['photo_url'];
                  final age = profile?['age']; // Might be null
                  final profession = profile?['profession'] ?? 'Sin profesión';
                  final aptTitle = apt?['title'] ?? 'Departamento';
                  // ignore: unused_local_variable
                  final createdAt =
                      DateTime.tryParse(req['created_at'] ?? '') ??
                          DateTime.now();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        ProfileAvatar(
                          imageUrl: photoUrl,
                          name: name,
                          size: 50,
                          borderRadius: 50,
                        ),
                        const SizedBox(width: 16),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                age != null ? '$name, $age' : name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                profession,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.home,
                                      size: 12, color: Color(0xFFFF4B63)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      aptTitle,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action
                        if (_requestsTabIndex == 0) ...[
                          // Received Actions (Accept/Reject)
                          Column(
                            children: [
                              InkWell(
                                onTap: () => _handleAccept(
                                  swipeId: req['id'],
                                  otherUserId: req['user_id'],
                                  apartmentId: req['apartment_id'],
                                  otherName: name,
                                  otherPhotoUrl: photoUrl ?? '',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF4B63),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.favorite,
                                      size: 20, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _handleReject(req['id']),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 20, color: Colors.grey),
                                ),
                              ),
                            ],
                          )
                        ] else ...[
                          // Sent Action (Cancel)
                          InkWell(
                            onTap: () => _handleCancelSent(req['id']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} días';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} horas';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} minutos';
    return 'Hace un momento';
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String name,
    required String lastMessage,
    required String time,
    required String chatId,
    String? avatar,
  }) {
    return InkWell(
      onTap: () => context.push('/chat/$chatId'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ProfileAvatar(
              imageUrl: avatar,
              name: name,
              size: 56,
              borderRadius: 50,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
