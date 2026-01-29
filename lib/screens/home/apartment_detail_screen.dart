import 'package:flutter/material.dart';
import 'package:roomie_app/services/match_service.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomie_app/services/ad_service.dart';

class ApartmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> apartment;
  final bool isViewOnly;

  const ApartmentDetailScreen({
    super.key,
    required this.apartment,
    this.isViewOnly = false,
  });

  @override
  State<ApartmentDetailScreen> createState() => _ApartmentDetailScreenState();
}

class _ApartmentDetailScreenState extends State<ApartmentDetailScreen> {
  final MatchService _matchService = MatchService();
  bool _isActionProcessing = false;

  Future<void> _handleSwipe(String type) async {
    if (_isActionProcessing) return;
    setState(() => _isActionProcessing = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Ad Check (shared logic with Feed)
      if (mounted) {
        AdService.incrementActionAndCheck(context);
      }

      await _matchService.recordSwipe(
        apartmentId: widget.apartment['id'],
        ownerId: widget.apartment['owner_id'],
        type: type,
      );

      if (mounted) {
        if (type == 'like') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Te ha gustado!'),
              backgroundColor: Color(0xFFFF4B63),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
        // Return 'true' to indicate a swipe occurred so Map can remove pin
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error swiping: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.apartment;
    final profile = apt['profiles']; // Using joined data
    final images = List<String>.from(apt['images'] ?? []);
    final firstImage = images.isNotEmpty ? images.first : null;
    final price = apt['price']?.toString() ?? '0';
    final title = apt['title'] ?? 'Sin título';
    final description = apt['description'] ?? 'Sin descripción';
    // Amenities could be a list in DB, assuming basics for now

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0C),
      body: Stack(
        children: [
          // Scrollable Content
          CustomScrollView(
            slivers: [
              // Image Header
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: const Color(0xFF0B0B0C),
                flexibleSpace: FlexibleSpaceBar(
                  background: firstImage != null
                      ? Image.network(
                          firstImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[900]),
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.image_not_supported,
                              size: 64, color: Colors.white24),
                        ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title, // e.g. "Departamento en La Carolina"
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4B63).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFFFF4B63), width: 1),
                            ),
                            child: Text(
                              '\$$price/mes',
                              style: const TextStyle(
                                color: Color(0xFFFF4B63),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Owner Profile
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ProfileAvatar(
                              imageUrl: profile?['photo_url'],
                              name: profile?['full_name'] ?? 'Usuario',
                              size: 48,
                              borderRadius: 50,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?['full_name'] ?? 'Usuario',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Propietario',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      // Extra space for FABs
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Action Buttons (Sticky Bottom)
          if (!widget.isViewOnly)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dislike Button
                  FloatingActionButton(
                    heroTag: 'dislike_detail',
                    onPressed: () => _handleSwipe('dislike'),
                    backgroundColor: const Color(0xFF2C2C2E),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 40),
                  // Like Button
                  FloatingActionButton(
                    heroTag: 'like_detail',
                    onPressed: () => _handleSwipe('like'),
                    backgroundColor: const Color(0xFFFF4B63),
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
