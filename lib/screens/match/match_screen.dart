import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

              // Match Icon
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5989B).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5989B),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE5989B).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: Color(0xFFE5989B),
                  size: 80,
                ),
              ),

              const SizedBox(height: 32),

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
                        // Just go back to swipe screen
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          // Fallback if no history
                          context.go('/home');
                        }
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
                          Icon(Icons.chat_bubble_outline, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Ir a los chats',
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
