import 'package:flutter/material.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/swipe_card.dart';
import 'package:roomie_app/widgets/blurred_swipe_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomie_app/services/match_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/auth_provider.dart';
import 'package:roomie_app/services/ad_service.dart';
import 'package:roomie_app/services/realtime_service.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/providers/theme_provider.dart';

class SwipeCardsScreen extends StatefulWidget {
  const SwipeCardsScreen({super.key});

  @override
  State<SwipeCardsScreen> createState() => _SwipeCardsScreenState();
}

class _SwipeCardsScreenState extends State<SwipeCardsScreen> {
  // final PageController _pageController = PageController(); // Removed

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

    // Initialize Ads
    AdService.init();

    // Initialize Realtime Notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RealtimeService().init(context);
    });

    // Ensure premium status is up to date and check for startup ad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider =
          Provider.of<ThemeProvider>(context, listen: false); // Add this
      authProvider.checkPremiumStatus().then((_) {
        themeProvider.validateThemeAccess(authProvider.isPremium);
        AdService.checkAndShowStartupAd(context);
      });
    });

    // Periodic check (every 5 minutes)
    /* 
    // Uncomment for periodic updates if not relying solely on actions
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) AdService.checkPeriodic(context);
    });
    */
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
          .neq('owner_id', user.id)
          .eq('is_active', true)
          .limit(50);

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

    final apt = _apartments[0];

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
    // 4. Move to next card (Remove current top card)
    setState(() {
      _apartments.removeAt(0);
      // _currentIndex is always 0 as we operate on the list head
    });
  }

  void _onSwipeLeft() {
    AdService.incrementActionAndCheck(context);
    _checkLimitAndSwipe('dislike');
  }

  Future<void> _onSwipeRight(String apartmentId) async {
    // Show Ad check
    AdService.incrementActionAndCheck(context);
    _checkLimitAndSwipe('like');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme =
        themeProvider.getThemeById(themeProvider.currentThemeId);

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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _apartments.isEmpty
                          ? _buildNoMoreCards()
                          : _buildCardsStack(),
                ),
              ],
            ),
          ),
          // Map Button (Floating) - Themed
          Positioned(
            bottom: 100, // Above bottom nav
            right: 20,
            child: FloatingActionButton(
              heroTag: 'map_btn',
              onPressed: () {
                context.push('/map', extra: _apartments);
              },
              backgroundColor: themeProvider.isDefaultTheme
                  ? const Color(0xFFE57373)
                  : (currentTheme['primaryColor'] as Color),
              child: const Icon(Icons.map, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 2,
      ),
    );
  }

  Widget _buildNoMoreCards() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'No hay más perfiles',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadApartments,
            child: const Text('Actualizar',
                style: TextStyle(color: Color(0xFFE57373))),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsStack() {
    // Show top 2 cards. Index 0 is Top. Index 1 is Next.
    final visibleApartments = _apartments.take(2).toList();

    // Stack paints first child at bottom, last child at top.
    // We want Index 0 on Top, so it must be last in the Stack children list.
    // Order in Stack Children: [Index 1, Index 0]
    final stackChildren = visibleApartments.reversed.map((apartment) {
      final index = _apartments.indexOf(apartment);
      final isTopCard = index == 0;

      return Positioned.fill(
        child: isTopCard
            ? Draggable(
                data: 'swipe',
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 32,
                    height: MediaQuery.of(context).size.height * 0.7,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: SwipeCard(
                      apartment: apartment,
                      onSwipeLeft: () {}, // Feedback visual only
                      onSwipeRight: () {},
                    ),
                  ),
                ),
                childWhenDragging: const SizedBox.shrink(),
                onDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 500) {
                    _onSwipeRight(apartment['id']);
                  } else if (details.velocity.pixelsPerSecond.dx < -500) {
                    _onSwipeLeft();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: SwipeCard(
                    apartment: apartment,
                    onSwipeLeft: _onSwipeLeft,
                    onSwipeRight: () => _onSwipeRight(apartment['id']),
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(
                    top: 10.0, // Slight offset for background card
                    bottom: 30.0,
                    left: 16,
                    right: 16),
                child: BlurredSwipeCard(
                  onTap: () {},
                ),
              ),
      );
    }).toList();

    return Stack(children: stackChildren);
  }
}
