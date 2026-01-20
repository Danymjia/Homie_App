import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/location_provider.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapScreenV2 extends StatefulWidget {
  const MapScreenV2({super.key});

  @override
  State<MapScreenV2> createState() => _MapScreenV2State();
}

class _MapScreenV2State extends State<MapScreenV2> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  // User profile data
  String _userName = 'Usuario';
  String? _profilePhotoUrl;

  // Cities data for Ecuador
  final Map<String, LatLng> _ecuadorCities = {
    'Quito': const LatLng(-0.1807, -78.4678),
    'Guayaquil': const LatLng(-2.1962, -79.8862),
    'Cuenca': const LatLng(-2.9001, -79.0045),
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadLocation();
    _loadApartments();
  }

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
        });
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  void _showCitiesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Selecciona una ciudad',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _ecuadorCities.entries.map((entry) {
            return ListTile(
              title: Text(
                entry.key,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _moveToCity(entry.key, entry.value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _moveToCity(String cityName, LatLng coordinates) {
    _mapController.move(coordinates, 12.0);
  }

  void _showEcuadorView() {
    // Mostrar todo Ecuador
    _mapController.move(const LatLng(-1.8314, -78.1834), 6.5);
  }

  Future<void> _loadLocation() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.getCurrentLocation();

    if (locationProvider.currentPosition != null && mounted) {
      _mapController.move(
        LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        ),
        14.0,
      );
    }
  }

  void _loadApartments() {
    // Mock data - En producción vendría de Supabase
    final apartments = [
      {
        'id': '1',
        'lat': 40.7128,
        'lng': -74.0060,
        'title': 'Modern Loft',
        'price': 1200,
      },
      {
        'id': '2',
        'lat': 40.7580,
        'lng': -73.9855,
        'title': 'Cozy Studio',
        'price': 950,
      },
    ];

    setState(() {
      _markers.clear();
      for (var apt in apartments) {
        _markers.add(
          Marker(
            point: LatLng(apt['lat'] as double, apt['lng'] as double),
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                _showApartmentDetails(apt);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home, color: Colors.white, size: 20),
                    Text(
                      '\$${apt['price']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    });
  }

  void _showApartmentDetails(Map<String, dynamic> apartment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              apartment['title'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${apartment['price']}/mes',
              style: const TextStyle(
                color: Color(0xFFE57373),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navegar a detalles del apartamento
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE57373),
                ),
                child: const Text('Ver Detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final currentPosition = locationProvider.currentPosition;

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
              MarkerLayer(markers: _markers),
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
                          color: const Color(0xFFE57373),
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
                      border: Border.all(color: Colors.yellow, width: 2),
                      color: const Color(0xFF1A1A1A),
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
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Quito, Ecuador',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Icon(
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
                  onTap: _showEcuadorView,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4B63),
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
                  backgroundColor: const Color(0xFFFF4B63),
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
                color: Colors.black.withOpacity(0.6),
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
