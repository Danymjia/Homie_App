import 'package:flutter/material.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';
import 'package:roomie_app/widgets/rating_dialog.dart';
import 'package:go_router/go_router.dart';

class SwipeCard extends StatefulWidget {
  final Map<String, dynamic> apartment;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const SwipeCard({
    super.key,
    required this.apartment,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  int _currentImageIndex = 0;

  List<String> get _images {
    final imgs = widget.apartment['images'];
    if (imgs is List) {
      if (imgs.isEmpty) return ['https://via.placeholder.com/400x600'];
      return imgs.map((e) => e.toString()).toList();
    }
    return ['https://via.placeholder.com/400x600'];
  }

  void _nextImage() {
    if (_images.length > 1) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _images.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151517),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image section
          Expanded(
            flex: 60,
            child: GestureDetector(
              onTap: _nextImage,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    child: Image.network(
                      images[_currentImageIndex],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                            child:
                                Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Progress indicators
                  if (images.length > 1)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: List.generate(images.length, (index) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: index == _currentImageIndex
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                  // Photo Counter Badge
                  if (images.length > 1)
                    Positioned(
                      top: 24,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${images.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  // Title and Price Overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${widget.apartment['price']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '/ mes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Map Icon Button
                            GestureDetector(
                              onTap: () {
                                context.push('/map', extra: [widget.apartment]);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.map,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.apartment['title'] ??
                              widget.apartment['location'] ??
                              '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          widget.apartment['address'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info section
          Expanded(
            flex: 40,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151517),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Roommate info (Owner)
                    Row(
                      children: [
                        ProfileAvatar(
                          imageUrl: widget.apartment['profiles']?['photo_url'],
                          name: widget.apartment['profiles']?['full_name'] ??
                              'Usuario',
                          size: 32,
                          borderRadius: 50,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.apartment['profiles']?['full_name'] ??
                                  'Usuario',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Propietario',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      widget.apartment['description'] ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Amenities
                    if (widget.apartment['amenities'] != null &&
                        (widget.apartment['amenities'] as List).isNotEmpty) ...[
                      const Text(
                        'Servicios',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (widget.apartment['amenities'] as List)
                            .map((amenity) => Chip(
                                  label: Text(amenity.toString(),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  backgroundColor: const Color(0xFF27272A),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Rules
                    if (widget.apartment['rules'] != null &&
                        (widget.apartment['rules'] as List).isNotEmpty) ...[
                      const Text(
                        'Reglas',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (widget.apartment['rules'] as List)
                            .map((rule) => Chip(
                                  label: Text(rule.toString(),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  backgroundColor: const Color(0xFF27272A),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Rating Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => RatingDialog(
                              onSubmitted: (rating, comment) {
                                // TODO: Implement actual service call in production
                                debugPrint(
                                    'Rating submitted: $rating stars. Comment: $comment');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('¡Gracias por tu valoración!')),
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.star, color: Colors.amber),
                        label: const Text('Valorar Publicación'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
