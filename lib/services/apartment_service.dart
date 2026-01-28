import 'package:image_picker/image_picker.dart';
import 'package:roomie_app/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApartmentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();

  Future<void> createApartment({
    required String title,
    required String description,
    required double price,
    required String address,
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required List<String> rules, // ["No smoking", "No pets"]
    required List<String> expenses, // ["Water", "Internet"]
    required List<XFile> images,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      // 0. Check Limit (Max 5)
      final countRes = await _supabase
          .from('apartments')
          .count(CountOption.exact)
          .eq('owner_id', user.id);

      if (countRes >= 5) {
        throw Exception(
            'Has alcanzado el límite de 5 habitaciones registradas.');
      }

      // 1. Upload Images
      final List<String> imageUrls =
          await _storageService.uploadApartmentPhotos(images);

      // 2. Insert into Database
      await _supabase.from('apartments').insert({
        'owner_id': user.id,
        'title': title,
        'description': description,
        'price': price,
        'address': address,
        'city': city,
        'country': country,
        'lat': latitude,
        'lng': longitude,
        'rules':
            rules, // Supabase handles List<String> as array/jsonb depending on column type
        'amenities':
            expenses, // Using amenities col for expenses/services for now
        'images': imageUrls,
        // 'created_at' is default
      });
    } catch (e) {
      throw Exception('Error al crear departamento: $e');
    }
  }

  // Future<List<Map<String, dynamic>>> getApartments() async { ... }
  // (Home screen does this directly currently, can refactor later)
}
