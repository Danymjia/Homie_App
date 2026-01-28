import 'package:flutter/material.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/swipe_card.dart';
import 'package:roomie_app/widgets/blurred_swipe_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomie_app/services/match_service.dart';
import 'package:roomie_app/screens/premium/premium_features_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/auth_provider.dart';

class SwipeCardsScreen extends StatefulWidget {
  const SwipeCardsScreen({super.key});

  @override
  State<SwipeCardsScreen> createState() => _SwipeCardsScreenState();
}

class _SwipeCardsScreenState extends State<SwipeCardsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final SupabaseClient _supabase = Supabase.instance.client;
  final MatchService _matchService = MatchService();

  List<Map<String, dynamic>> _apartments = [];
  bool _isLoading = true;
  int _dailySwipes = 0;
  static const int _maxDailySwipes = 5;

  void initState() {
    super.initState();
    _checkPermissions();
    _loadApartments();
    // Ensure premium status is up to date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkPremiumStatus();
    });
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.camera,
      Permission.location,
    ].request();
  }

  Future<void> _loadApartments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // 1. Get IDs of already swiped apartments
      final swipedIds = await _matchService.getSwipedApartmentIds();

      // 2. Counts daily swipes
      final count = await _matchService.getDailySwipeCount();

      // 3. Fetch candidates (excluding swiped)
      // 3. Fetch candidates (excluding swiped)
      final response = await _supabase
          .from('apartments')
          .select('*, profiles:owner_id(full_name, photo_url)')
          .neq('owner_id', user.id);

      final candidates = List<Map<String, dynamic>>.from(response);

      // Filter out swiped
      final filtered =
          candidates.where((apt) => !swipedIds.contains(apt['id'])).toList();

      if (mounted) {
        setState(() {
          _apartments = filtered;
          _dailySwipes = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading apartments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _checkLimitAndSwipe(String type) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isPremium = authProvider.isPremium;

    if (!isPremium && _dailySwipes >= _maxDailySwipes) {
      // Limit reached, UI handles it.
      return;
    }

    final apt = _apartments[_currentIndex];

    // Optimistic UI update
    // 1. Record swipe in background
    _matchService.recordSwipe(
      apartmentId: apt['id'],
      ownerId: apt['owner_id'],
      type: type,
    );

    // 2. Increment local count
    setState(() {
      _dailySwipes++;
    });

    // 3. Show feedback
    if (type == 'like') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Te ha gustado!'),
            duration: Duration(milliseconds: 300)),
      );
    }

    // 4. Move to next card
    if (_currentIndex < _apartments.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Remove the last card visually if needed or show empty state
      setState(() {
        // This triggers the empty state rebuild if list becomes empty
        _apartments.removeAt(_currentIndex);
        if (_currentIndex > 0) _currentIndex--;
      });
    }
  }

  void _onSwipeLeft() {
    _checkLimitAndSwipe('dislike');
  }

  Future<void> _onSwipeRight(String apartmentId) async {
    _checkLimitAndSwipe('like');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B0C),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: BottomNavBar(currentIndex: 2),
      );
    }

    if (_apartments.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B0C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay publicaciones disponibles',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: 2),
      );
    }

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
                        'Habitaciones disponibles',
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

            // Cards or Blurred State
            Expanded(
              child: (!Provider.of<AuthProvider>(context).isPremium &&
                      _dailySwipes >= _maxDailySwipes)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: BlurredSwipeCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PremiumFeaturesScreen(),
                            ),
                          );
                        },
                      ),
                    )
                  : Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemCount: _apartments.length,
                          itemBuilder: (context, index) {
                            final apt = _apartments[index];
                            // Adapt Supabase data to SwipeCard widget expectation
                            // Extract profile data safely
                            final profileData = apt['profiles'];
                            final String ownerName = (profileData != null)
                                ? (profileData['full_name'] ?? 'Usuario')
                                : 'Usuario';
                            final String? ownerPhoto = (profileData != null)
                                ? profileData['photo_url']
                                : null;

                            final mappedApt = {
                              'id': apt['id'],
                              'price': apt['price'],
                              'location': apt['city'] ??
                                  apt['address'] ??
                                  'Ubicación desconocida',
                              'rating': 0.0,
                              'images': apt['images'] is List
                                  ? apt['images']
                                  : (apt['image_url'] != null
                                      ? [apt['image_url']]
                                      : []),
                              'roommate': {
                                'name': ownerName,
                                'photo': ownerPhoto
                              },
                              'description': apt['description'],
                              'amenities': apt['amenities'] ?? [],
                              'rules': apt['rules'] ?? [],
                              'isNew': false,
                            };

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: SwipeCard(
                                apartment: mappedApt,
                                onSwipeLeft: _onSwipeLeft,
                                onSwipeRight: () =>
                                    _onSwipeRight(apt['id'].toString()),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),

            // Action buttons (Only if not limited)
            if (Provider.of<AuthProvider>(context).isPremium ||
                _dailySwipes < _maxDailySwipes)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            size: 32, color: Colors.red),
                        onPressed: _onSwipeLeft,
                      ),
                    ),
                    const SizedBox(width: 24),
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
                        icon: const Icon(Icons.favorite,
                            size: 32, color: Colors.white),
                        onPressed: () => _onSwipeRight(
                            _apartments[_currentIndex]['id'].toString()),
                      ),
                    ),
                  ],
                ),
              ),
            if (!Provider.of<AuthProvider>(context).isPremium &&
                _dailySwipes >= _maxDailySwipes)
              const SizedBox(height: 96), // Spacer for bottom layout
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
