import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Los servicios de ubicación están deshabilitados';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Los permisos de ubicación fueron denegados';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _error = 'Los permisos de ubicación están permanentemente denegados';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener la ubicación: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
