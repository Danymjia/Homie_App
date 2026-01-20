import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B).withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.map,
                label: 'Map',
                index: 0,
                route: '/map',
              ),
              _buildNavItem(
                context,
                icon: Icons.chat_bubble,
                label: 'Chats',
                index: 1,
                route: '/chats',
                hasNotification: true,
              ),
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Home',
                index: 2,
                route: '/home',
                isActive: true,
              ),
              _buildNavItem(
                context,
                icon: Icons.person,
                label: 'Profile',
                index: 3,
                route: '/profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required String route,
    bool hasNotification = false,
    bool isActive = false,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected || isActive
        ? const Color(0xFFFF4D67)
        : Colors.grey;

    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected || isActive
                      ? Colors.white.withOpacity(0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              if (hasNotification && !isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D67),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0B0B0B), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected || isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
