import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';
import 'package:roomie_app/services/chat_service.dart';
import 'package:roomie_app/services/match_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roomie_app/screens/match/match_screen.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
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
          indicatorColor: const Color(0xFFFF4B63),
          labelColor: const Color(0xFFFF4B63),
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _matchService.getIncomingLikes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tienes nuevas solicitudes.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final profile = req['profiles'] as Map<String, dynamic>?;
            final apt = req['apartments'] as Map<String, dynamic>?;

            final name = profile?['full_name'] ?? 'Usuario';
            final photoUrl = profile?['photo_url'];
            final age = profile?['age'] ?? 0;
            // aptTitle isn't in strict design but good for context.
            // Design shows: "Modern Loft, San Francisco" and profession.
            final profession =
                profile?['profession'] ?? 'Estudiante'; // Fallback
            final location = apt?['title'] ?? 'Tu publicación';
            final createdAt =
                DateTime.tryParse(req['created_at'] ?? '') ?? DateTime.now();
            final timeAgo = _getTimeAgo(createdAt);

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
                  // Avatar with Heart Badge
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFFF4B63), width: 1),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ProfileAvatar(
                          imageUrl: photoUrl,
                          name: name,
                          size: 60,
                          borderRadius: 50,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4B63),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name, $age',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profession,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.home,
                                size: 12,
                                color:
                                    const Color(0xFFFF4B63).withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Column(
                    children: [
                      // Accept Button
                      InkWell(
                        onTap: () => _handleAccept(
                          swipeId: req['id'],
                          otherUserId: req['user_id'],
                          apartmentId: req['apartment_id'],
                          otherName: name,
                          otherPhotoUrl: photoUrl ?? '',
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4B63),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Reject Button
                      InkWell(
                        onTap: () => _handleReject(req['id']),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.grey, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
