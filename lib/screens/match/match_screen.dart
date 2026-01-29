import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchScreen extends StatefulWidget {
  final String chatId;
  final String myPhotoUrl;
  final String otherPhotoUrl;
  final String otherName;
  final String otherUserId;

  const MatchScreen({
    super.key,
    required this.chatId,
    required this.myPhotoUrl,
    required this.otherPhotoUrl,
    required this.otherName,
    this.otherUserId =
        '', // Optional for backward compatibility, but needed for algorithm
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int _similarityPercentage = 0;
  bool _calculating = true;

  @override
  void initState() {
    super.initState();
    _calculateCompatibility();
  }

  Future<void> _calculateCompatibility() async {
    // Artificial delay for effect
    await Future.delayed(const Duration(milliseconds: 500));

    if (widget.otherUserId.isEmpty) {
      if (mounted) setState(() => _calculating = false);
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return;

      // Fetch compatibility data for both
      final response = await supabase
          .from('profiles')
          .select('id, compatibility_data, lifestyle_tags')
          .inFilter('id', [myId, widget.otherUserId]);

      final myProfile = response.firstWhere((p) => p['id'] == myId,
          orElse: () => <String, dynamic>{});
      final otherProfile = response.firstWhere(
          (p) => p['id'] == widget.otherUserId,
          orElse: () => <String, dynamic>{});

      if (myProfile.isNotEmpty && otherProfile.isNotEmpty) {
        // Calculate based on tags intersection
        final myTags = List<String>.from(myProfile['lifestyle_tags'] ?? []);
        final otherTags =
            List<String>.from(otherProfile['lifestyle_tags'] ?? []);

        int matchCount = 0;
        for (final tag in myTags) {
          if (otherTags.contains(tag)) matchCount++;
        }

        // Simple algorithm: 50% base + 10% per shared tag (capped at 95%)
        // Or if compatibility_data JSON exists, use that.
        // Assuming compatibility_data is NULL for now or simple JSON.

        int score = 50 + (matchCount * 10);
        if (score > 98) score = 98;

        if (mounted)
          setState(() {
            _similarityPercentage = score;
            _calculating = false;
          });
      } else {
        if (mounted) setState(() => _calculating = false);
      }
    } catch (e) {
      debugPrint('Error calculating compatibility: $e');
      if (mounted) setState(() => _calculating = false);
    }
  }

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
                        imageUrl: widget.myPhotoUrl.isNotEmpty
                            ? widget.myPhotoUrl
                            : null,
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
                        imageUrl: widget.otherPhotoUrl.isNotEmpty
                            ? widget.otherPhotoUrl
                            : null,
                        name: widget.otherName,
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

              const SizedBox(height: 32),

              // Compatibility Percentage
              if (!_calculating && _similarityPercentage > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFE5989B).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Color(0xFFE5989B), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$_similarityPercentage% Compatible',
                        style: const TextStyle(
                          color: Color(0xFFE5989B),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Compatibility text
              Text(
                'Tú y ${widget.otherName} podrían ser excelentes roomies',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _calculating
                    ? 'Calculando compatibilidad...'
                    : 'Basado en sus intereses y preferencias',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                        context.pushReplacement('/chat/${widget.chatId}');
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
