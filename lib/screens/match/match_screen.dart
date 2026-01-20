import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';

class MatchScreen extends StatelessWidget {
  final String userId;

  const MatchScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Title
              const Text(
                '¡Es un Match!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 48),

              // Profile images
              Stack(
                alignment: Alignment.center,
                children: [
                  // Left profile
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.15,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5989B),
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5989B).withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ProfileAvatar(
                        imageUrl: null, // Current user's profile photo
                        name: 'You',
                        size: 128,
                        borderRadius: 50,
                      ),
                    ),
                  ),
                  // Right profile
                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.15,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5989B),
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5989B).withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ProfileAvatar(
                        imageUrl: null, // Matched user's profile photo
                        name: 'Matched User',
                        size: 128,
                        borderRadius: 50,
                      ),
                    ),
                  ),
                  // Heart icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5989B),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF000000),
                        width: 6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE5989B).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFF000000),
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Compatibility text
              const Text(
                'Tú y Sofia podrían ser excelentes roomies',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tienen 85% de compatibilidad en hábitos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const Spacer(),

              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar al chat
                        context.push('/chat/match_$userId');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5989B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble, color: Colors.black),
                          const SizedBox(width: 8),
                          const Text(
                            'Enviar Mensaje',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.go('/home'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3F3F46)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Seguir Buscando',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
