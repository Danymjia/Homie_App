import 'package:flutter/material.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/swipe_card.dart';

class SwipeCardsScreen extends StatefulWidget {
  const SwipeCardsScreen({super.key});

  @override
  State<SwipeCardsScreen> createState() => _SwipeCardsScreenState();
}

class _SwipeCardsScreenState extends State<SwipeCardsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Mock data - En producción vendría de Supabase
  final List<Map<String, dynamic>> _apartments = [
    {
      'id': '1',
      'price': 950,
      'location': 'Modern Loft, San Francisco',
      'rating': 4.8,
      'images': ['https://cf.bstatic.com/xdata/images/hotel/max1024x768/697485066.webp?k=a7685b9db668687c8f029981e28fca7f6094b3500041660120aa8cb0c3f29331&o='],
      'roommate': {
        'name': 'Sarah',
        'age': 24,
        'profession': 'Software Engineer',
        'photo': 'https://via.placeholder.com/100',
      },
      'description': 'Looking for a chill roommate for my extra bedroom. I\'m tidy, love weekend hikes...',
      'amenities': ['Gigabit', 'Laundry', 'Pets'],
      'isNew': true,
    },
    // Más apartamentos...
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSwipeLeft() {
    if (_currentIndex < _apartments.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onSwipeRight(String apartmentId) {
    // Aquí se manejaría el like/match
    // Por ahora solo avanzamos a la siguiente tarjeta
    if (_currentIndex < _apartments.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0C),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4D67), Color(0xFFE91E63)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.style,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Encuentra tu compañero ideal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151517),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.grey,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Cards
            Expanded(
              child: Stack(
                children: [
                  // Background cards
                  if (_currentIndex < _apartments.length - 1)
                    Positioned(
                      top: 32,
                      left: 24,
                      right: 24,
                      bottom: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF27272A),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        transform: Matrix4.identity()
                          ..scale(0.95)
                          ..translate(0.0, 8.0),
                      ),
                    ),
                  if (_currentIndex < _apartments.length - 2)
                    Positioned(
                      top: 40,
                      left: 32,
                      right: 32,
                      bottom: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF27272A),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        transform: Matrix4.identity()
                          ..scale(0.90)
                          ..translate(0.0, 16.0),
                      ),
                    ),

                  // Main card
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: _apartments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SwipeCard(
                          apartment: _apartments[index],
                          onSwipeLeft: _onSwipeLeft,
                          onSwipeRight: () => _onSwipeRight(_apartments[index]['id']),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dislike button
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 32, color: Colors.red),
                      onPressed: _onSwipeLeft,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Super like button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const IconButton(
                      icon: Icon(Icons.star, size: 24, color: Colors.amber),
                      onPressed: null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Like button
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4D67), Color(0xFFE91E63)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4D67).withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite, size: 32, color: Colors.white),
                      onPressed: () => _onSwipeRight(_apartments[_currentIndex]['id']),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
