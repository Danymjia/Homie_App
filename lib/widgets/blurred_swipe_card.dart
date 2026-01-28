import 'package:flutter/material.dart';
import 'dart:ui';

class BlurredSwipeCard extends StatelessWidget {
  final VoidCallback onTap;

  const BlurredSwipeCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          color: const Color(0xFF151517), // card-dark
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070&auto=format&fit=crop', // Modern apartment
                fit: BoxFit.cover,
              ),
            ),

            // Blur Effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),

            // Lock Icon Center
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

            // Bottom Buttons Visual (Non-interactive)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFakeButton(Icons.close, Colors.red, 64),
                  _buildFakeButton(Icons.star, Colors.amber, 48),
                  _buildFakeButton(Icons.favorite, Colors.pink, 64),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFakeButton(IconData icon, Color color, double size) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF27272A), // surface
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}
