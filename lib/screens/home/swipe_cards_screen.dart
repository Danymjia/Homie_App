import 'package:flutter/material.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/swipe_card.dart';
import 'package:roomie_app/widgets/blurred_swipe_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomie_app/services/match_service.dart';
import 'package:roomie_app/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/auth_provider.dart';
import 'package:roomie_app/services/ad_service.dart';
import 'package:roomie_app/services/realtime_service.dart';
import 'package:roomie_app/providers/theme_provider.dart';
import 'package:roomie_app/screens/match/match_screen.dart';

class SwipeCardsScreen extends StatefulWidget {
  const SwipeCardsScreen({super.key});

  @override
  State<SwipeCardsScreen> createState() => _SwipeCardsScreenState();
}

class _SwipeCardsScreenState extends State<SwipeCardsScreen> {
  // final PageController _pageController = PageController(); // Removed

  final SupabaseClient _supabase = Supabase.instance.client;
  final MatchService _matchService = MatchService();
  final NotificationService _notificationService = NotificationService();

  List<Map<String, dynamic>> _apartments = [];
  bool _isLoading = true;
  int _dailySwipes = 0;
  static const int _maxDailySwipes = 5;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadApartments();
    _notificationService.init();

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
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.camera,
      Permission.location,
      Permission.notification,
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
      _showLimitReachedDialog();
      return;
    }

    final apt = _apartments[0];
    // Keep a reference before removing
    final swipedApt = apt;

    // Optimistic UI update
    // 1. Record swipe in background
    // We defer this in _onSwipeRight for Matches, but for 'dislike' we do it here?
    // The original code did recordSwipe here.
    // For 'like', we need to record it to check match.
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Text('¡Te ha gustado!'),
      //       duration: Duration(milliseconds: 300)),
      // );
    }

    // 4. Move to next card
    setState(() {
      _apartments.removeAt(0);
    });

    // 5. Check Match logic (if like)
    if (type == 'like') {
      _handleMatchCheck(swipedApt);
    }
  }

  Future<void> _handleMatchCheck(Map<String, dynamic> apt) async {
    final myUser = _supabase.auth.currentUser;
    if (myUser == null) return;

    final ownerId = apt['owner_id'];
    final isMatch = await _matchService.checkIfMatch(myUser.id, ownerId);

    if (isMatch && mounted) {
      // Create Chat? The MatchService.acceptMatch usually creates it.
      // But here we are just detecting it.
      // Usually we need to "solidify" the match.
      // However, usually "checkIfMatch" just checks if the other person liked me.
      // If so, we can consider it a match.
      // We might need to call strict creation of chat or just let the Match Screen handle it?
      // The MatchService has `acceptMatch` which creates the chat and deletes the swipe.
      // BUT, `recordSwipe` inserts a swipe.
      // If we have a match, we should probably CONVERT these swipes into a Chat.
      // For now, let's assume we just show the screen and notification.

      // Notify ME (The user who just swiped)
      _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '¡Nuevo Match!',
        body:
            'Has hecho match con ${apt['profiles']['full_name'] ?? 'alguien'}',
      );

      // Fetch my profile photo for the screen
      final myProfile = await _supabase
          .from('profiles')
          .select('photo_url')
          .eq('id', myUser.id)
          .single();
      final myPhotoUrl = myProfile['photo_url'] ?? '';

      // Go to Match Screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MatchScreen(
              chatId:
                  'temp_id', // We might not have chat ID yet unless we create it
              myPhotoUrl: myPhotoUrl,
              otherPhotoUrl: apt['profiles']['photo_url'] ?? '',
              otherName: apt['profiles']['full_name'] ?? 'Usuario',
              otherUserId: ownerId,
            ),
          ),
        );
      }
    }
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B0C),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: BottomNavBar(currentIndex: 2),
      );
    }

    if (_apartments.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0B0C),
        body: _buildNoMoreCards(),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),
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
                // Swipe Guide
                if (!_isLoading && _apartments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back,
                            color: Colors.white.withOpacity(0.5), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Desliza izq: Descartar',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        Container(
                            width: 1,
                            height: 12,
                            color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 16),
                        Text(
                          'Desliza der: Me gusta',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.white.withOpacity(0.5), size: 16),
                      ],
                    ),
                  ),
              ],
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
          // Loading Indicator for "Searching"
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFE57373)),
                  ),
                ),
                Icon(Icons.search,
                    size: 32, color: Colors.white.withOpacity(0.7)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Estamos buscando las mejores\nhabitaciones para ti',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Cargando las mejores habitaciones...',
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              if (!authProvider.isPremium && _dailySwipes >= _maxDailySwipes) {
                Navigator.pushNamed(context, '/premium/plans');
              } else {
                _loadApartments();
              }
            },
            child: const Text('Intentar de nuevo',
                style: TextStyle(color: Color(0xFFE57373))),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Límite diario alcanzado',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Has alcanzado tu límite de 5 swipes diarios. Actualiza a Premium para swipes ilimitados.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/premium/plans');
            },
            child: const Text('Ser Premium',
                style: TextStyle(
                    color: Color(0xFFE57373), fontWeight: FontWeight.bold)),
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
