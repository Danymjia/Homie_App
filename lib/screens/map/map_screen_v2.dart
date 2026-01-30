import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/location_provider.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:roomie_app/providers/theme_provider.dart';
import 'package:roomie_app/services/match_service.dart';
import 'package:roomie_app/screens/home/apartment_detail_screen.dart';

class MapScreenV2 extends StatefulWidget {
  final List<Map<String, dynamic>>? initialApartments;

  const MapScreenV2({super.key, this.initialApartments});

  @override
  State<MapScreenV2> createState() => _MapScreenV2State();
}

class _MapScreenV2State extends State<MapScreenV2> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  final MatchService _matchService = MatchService();
  List<Map<String, dynamic>> _visibleApartments = [];

  // User profile data
  String _userName = 'Usuario';
  String? _profilePhotoUrl;
  String? _city;
  String? _country;
  List<Map<String, String>> _availableCities = [];

  // Cities data by country (Same as compatibility screen)
  final Map<String, List<Map<String, String>>> _citiesByCountry = {
    'Ecuador': [
      {'name': 'Quito', 'image': ''},
      {'name': 'Guayaquil', 'image': ''},
      {'name': 'Cuenca', 'image': ''},
      {'name': 'Ambato', 'image': ''},
      {'name': 'Manta', 'image': ''},
    ],
    'Colombia': [],
    'Perú': [],
    'Argentina': [],
    'Chile': [],
    'México': [],
  };
  @override
  void initState() {
    super.initState();
    _loadProfileData();

    // If we have specific apartments passed, focus on them and don't load user location/others
    if (widget.initialApartments != null &&
        widget.initialApartments!.isNotEmpty) {
      _loadInitialApartments();
    } else {
      _loadLocation();
      _loadApartments();
    }
  }

  void _loadInitialApartments() {
    // Determine center from first apartment
    final first = widget.initialApartments!.first;
    final lat = first['lat'] as double? ?? 0.0;
    final lng = first['lng'] as double? ?? 0.0;

    if (lat != 0 && lng != 0) {
      // Move map logic will happen after built or we can try immediately if controller ready (but safety first)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(lat, lng), 15.0);
      });
    }

    setState(() {
      _visibleApartments = widget.initialApartments!;
      _markers.clear();
      for (var apt in _visibleApartments) {
        final alat = apt['lat'] as double? ?? 0.0;
        final alng = apt['lng'] as double? ?? 0.0;

        if (alat != 0 && alng != 0) {
          _markers.add(
            Marker(
              point: LatLng(alat, alng),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _showApartmentDetails(apt),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4B63),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          );
        }
      }
    });
  }

// ...

  Future<void> _loadProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _userName = response['full_name'] ?? 'Usuario';
          _profilePhotoUrl = response['photo_url'];
          _city = response['city'];
          _country = response['country'];

          if (_country != null) {
            _availableCities = _citiesByCountry[_country] ?? [];
          }
        });

        // REMOVED: Do not auto-center on city profile. Prioritize Real-time location.
        // if (_city != null && _country != null) {
        //   _centerOnCity(_city!, _country!);
        // }
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> _centerOnCity(String city, String country) async {
    try {
      List<Location> locations = await locationFromAddress("$city, $country");
      if (locations.isNotEmpty) {
        _mapController.move(
          LatLng(locations.first.latitude, locations.first.longitude),
          12.0,
        );
      }
    } catch (e) {
      debugPrint("Error geocoding city: $e");
    }
  }

  void _showCitiesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Selecciona una ciudad en ${_country ?? "tu país"}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableCities.length,
            itemBuilder: (context, index) {
              final city = _availableCities[index];
              return ListTile(
                title: Text(
                  city['name']!,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _moveToCity(city['name']!);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _moveToCity(String cityName) async {
    try {
      String query = cityName;
      if (_country != null) query += ", $_country";

      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        _mapController.move(
          LatLng(locations.first.latitude, locations.first.longitude),
          12.0,
        );
        setState(() => _city = cityName);
      }
    } catch (e) {
      debugPrint("Error moving to city: $e");
    }
  }

  Future<void> _showWorldView() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    LatLng center = const LatLng(-0.1807, -78.4678); // Default

    if (locationProvider.currentPosition != null) {
      center = LatLng(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );
    } else if (_city != null && _country != null) {
      try {
        List<Location> locations =
            await locationFromAddress("$_city, $_country");
        if (locations.isNotEmpty) {
          center = LatLng(locations.first.latitude, locations.first.longitude);
        }
      } catch (_) {}
    }

    _mapController.move(center, 5.0);
  }

  Future<void> _loadLocation() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    // Notify user we are looking for location
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obteniendo ubicación en tiempo real...'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black54,
        ),
      );
    }

    await locationProvider.getCurrentLocation();

    if (!mounted) return;

    if (locationProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locationProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
      // Fallback: If GPS fails, DO center on city profile as backup
      if (_city != null && _country != null) {
        _centerOnCity(_city!, _country!);
      }
      return;
    }

    if (locationProvider.currentPosition != null) {
      _mapController.move(
        LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        ),
        15.0, // Closer zoom for user location
      );
    }
  }

  Future<void> _loadApartments() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // 1. Get IDs of already swiped apartments
      final swipedIds = await _matchService.getSwipedApartmentIds();

      // 2. Fetch candidates (Active & Not Owner)
      // We fetch a bit more than 5 to account for swipes we filter client-side
      final response = await Supabase.instance.client
          .from('apartments')
          .select('*, profiles:owner_id(full_name, photo_url)')
          .neq('owner_id', user.id)
          .eq('is_active', true)
          .limit(20);

      final List<Map<String, dynamic>> candidates =
          List<Map<String, dynamic>>.from(response);

      // 3. Filter swiped and shuffle/take 5
      final filtered =
          candidates.where((apt) => !swipedIds.contains(apt['id'])).toList();

      // Shuffle to randomize which 5 are shown if pool is large
      filtered.shuffle();

      // Take top 5
      final limited = filtered.take(5).toList();

      if (mounted) {
        setState(() {
          _visibleApartments = limited;
          _markers.clear();
          for (var apt in limited) {
            final lat = apt['lat'] as double? ?? 0.0;
            final lng = apt['lng'] as double? ?? 0.0;

            if (lat != 0 && lng != 0) {
              _markers.add(
                Marker(
                  point: LatLng(lat, lng),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => _showApartmentDetails(apt),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4B63),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.home_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading map apartments: $e');
    }
  }

  void _showApartmentDetails(Map<String, dynamic> apartment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Apartment Image
            if (apartment['images'] != null &&
                (apartment['images'] as List).isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage((apartment['images'] as List)[0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    apartment['title'] ?? 'Sin Título',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4B63).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${apartment['price']}',
                    style: const TextStyle(
                      color: Color(0xFFFF4B63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              apartment['description'] ?? 'Sin descripción',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9), // Improved visibility
                fontSize: 14,
              ),
              maxLines: 4, // Increased lines
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            // Removed action button as requested
            const Text(
              'Para interactuar, búscala en la sección de Home.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _removeApartmentFromMap(String apartmentId) {
    setState(() {
      _visibleApartments.removeWhere((apt) => apt['id'] == apartmentId);
      // Rebuild markers based on remaining apartments
      _markers.clear();
      for (var apt in _visibleApartments) {
        final lat = apt['lat'] as double? ?? 0.0;
        final lng = apt['lng'] as double? ?? 0.0;
        if (lat != 0 && lng != 0) {
          _markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _showApartmentDetails(apt),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4B63),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final currentPosition = locationProvider.currentPosition;

    // Theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme =
        themeProvider.getThemeById(themeProvider.currentThemeId);
    final primaryColor = (currentTheme['primaryColor'] as Color);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition != null
                  ? LatLng(currentPosition.latitude, currentPosition.longitude)
                  : const LatLng(-0.1807, -78.4678), // Default: Quito, Ecuador
              initialZoom: 14.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roomie.app',
              ),
              MarkerLayer(
                  markers: _markers.map((m) {
                // Re-create marker with theme color if needed, or rely on _loadApartments using theme
                // Since _loadApartments runs once on init, it might not catch theme changes unless we rebuild markers
                // or move marker building to build method.
                // For now, let's keep _markers as is but ideally we should rebuild them.
                // Let's modify _loadApartments to clear and rebuild, or just map them here?
                // Mapping them here is hard because child is a widget.
                // Better to update _loadApartments to take color.
                // But for this interaction, I'll update the other UI elements first.
                return m;
              }).toList()), // Markers need to be updated in _loadApartments if we want them themed
              if (currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        currentPosition.latitude,
                        currentPosition.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top bar
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                      color: Theme.of(context).cardColor,
                    ),
                    child: ProfileAvatar(
                      imageUrl: _profilePhotoUrl,
                      name: _userName,
                      size: 40,
                      borderRadius: 50,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _showCitiesDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _city != null && _country != null
                                ? '$_city, $_country'
                                : 'Seleccionar ubicación',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.expand_more,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showWorldView,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.public,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search button
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/home'),
                icon: const Icon(Icons.favorite),
                label: const Text('Busca tu roomie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          // My location button
          Positioned(
            bottom: 100,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: IconButton(
                icon: const Icon(Icons.near_me, color: Colors.white),
                onPressed: _loadLocation,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
