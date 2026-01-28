import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';

class MatchScreen extends StatelessWidget {
  final String chatId;
  final String myPhotoUrl;
  final String otherPhotoUrl;
  final String otherName;

  const MatchScreen({
    super.key,
    required this.chatId,
    required this.myPhotoUrl,
    required this.otherPhotoUrl,
    required this.otherName,
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
                  // Left profile (Mine)
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.1,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5989B),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5989B).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ProfileAvatar(
                        imageUrl: myPhotoUrl.isNotEmpty ? myPhotoUrl : null,
                        name: 'Yo',
                        size: 110,
                        borderRadius: 50,
                      ),
                    ),
                  ),
                  // Right profile (Other)
                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.1,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5989B),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5989B).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ProfileAvatar(
                        imageUrl:
                            otherPhotoUrl.isNotEmpty ? otherPhotoUrl : null,
                        name: otherName,
                        size: 110,
                        borderRadius: 50,
                      ),
                    ),
                  ),
                  // Heart icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5989B),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF000000),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE5989B).withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFF000000),
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Compatibility text
              Text(
                'Tú y $otherName podrían ser excelentes roomies',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tienen 85% de compatibilidad en hábitos.', // Could be dynamic later
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
                        // Replace current route with Chat to avoid back stack loop
                        context.pushReplacement('/chat/$chatId');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5989B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
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
                      onPressed: () => Navigator.pop(context), // Back to list
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
