import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE57373), width: 2),
                ),
                child: ProfileAvatar(
                  imageUrl: null, // Current user's profile photo
                  name: 'User',
                  size: 40,
                  borderRadius: 50,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 48, right: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_comment,
                    color: Color(0xFFE57373),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search chats',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF171717),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Support section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'SUPPORT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          _buildSupportCard(context),
          const SizedBox(height: 24),

          // Conversations section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'CONVERSATIONS',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          _buildChatItem(
            context,
            name: 'Sarah Thompson',
            lastMessage: 'That sounds perfect! When can I come visit?',
            time: '2m',
            avatar: 'https://via.placeholder.com/56',
            hasUnread: true,
            isOnline: true,
          ),
          _buildChatItem(
            context,
            name: 'James Wilson',
            lastMessage: 'Hey, I saw your post about the downtown apartment...',
            time: '1h',
            avatar: 'https://via.placeholder.com/56',
          ),
          _buildChatItem(
            context,
            name: 'Elena Rodriguez',
            lastMessage: 'I\'m also a quiet person, mostly work from home.',
            time: '3h',
            avatar: 'https://via.placeholder.com/56',
          ),
          _buildChatItem(
            context,
            name: 'Apartment Search Squad',
            lastMessage: 'You: Definitely looking for someone by Oct 1st.',
            time: 'Yesterday',
            avatar: null,
            isGroup: true,
          ),
          _buildChatItem(
            context,
            name: 'Marcus Chen',
            lastMessage: 'Sent a photo',
            time: 'Tue',
            avatar: 'https://via.placeholder.com/56',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE57373).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE57373).withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE57373), Color(0xFFFF8A80)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE57373).withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Positioned(
                bottom: -1,
                right: -1,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Roomie Helper',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE57373).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE57373).withOpacity(0.2),
                        ),
                      ),
                      child: const Text(
                        'PINNED',
                        style: TextStyle(
                          color: Color(0xFFE57373),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'How can I help you find your perfect roommate today?',
                  style: TextStyle(
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
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String name,
    required String lastMessage,
    required String time,
    String? avatar,
    bool hasUnread = false,
    bool isOnline = false,
    bool isGroup = false,
  }) {
    return InkWell(
      onTap: () => context.push('/chat/chat_$name'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isGroup ? const Color(0xFF171717) : null,
                  ),
                  child: isGroup
                      ? const Icon(Icons.group, color: Colors.grey)
                      : ProfileAvatar(
                          imageUrl: avatar,
                          name: name,
                          size: 56,
                          borderRadius: 50,
                        ),
                ),
                if (isOnline && !isGroup)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE57373),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: hasUnread ? Colors.white : Colors.white,
                          fontSize: 16,
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color:
                              hasUnread ? const Color(0xFFE57373) : Colors.grey,
                          fontSize: 12,
                          fontWeight:
                              hasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            color: hasUnread ? Colors.white70 : Colors.grey,
                            fontSize: 14,
                            fontWeight:
                                hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE57373),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE57373).withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                    ],
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
