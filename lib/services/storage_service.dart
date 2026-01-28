import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // Upload profile photo
  Future<String?> uploadProfilePhoto(XFile imageFile) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final fileName =
          '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Leer el archivo
      final fileBytes = await imageFile.readAsBytes();

      // Subir a Supabase Storage
      await _supabase.storage.from('profile-photos').uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Obtener URL pública
      final publicUrl =
          _supabase.storage.from('profile-photos').getPublicUrl(fileName);

      // Actualizar perfil con la URL de la foto
      await _supabase.from('profiles').update({
        'photo_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return publicUrl;
    } catch (e) {
      throw Exception('Error al subir la foto: $e');
    }
  }

  // Upload apartment photos
  Future<List<String>> uploadApartmentPhotos(List<XFile> imageFiles) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final List<String> photoUrls = [];

    for (var i = 0; i < imageFiles.length; i++) {
      try {
        final fileName =
            '$userId/apt_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final fileBytes = await imageFiles[i].readAsBytes();

        await _supabase.storage.from('apartment-images').uploadBinary(
              fileName,
              fileBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );

        final publicUrl =
            _supabase.storage.from('apartment-images').getPublicUrl(fileName);

        photoUrls.add(publicUrl);
      } catch (e) {
        // Continuar con las demás fotos aunque una falle
        continue;
      }
    }

    return photoUrls;
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
    } catch (e) {
      return null;
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
    } catch (e) {
      return null;
    }
  }

  // Delete profile photo
  Future<void> deleteProfilePhoto() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Listar archivos del usuario
      final files = await _supabase.storage.from('profile-photos').list();

      // Filtrar archivos del usuario
      final userFiles = files
          .where((file) => file.name.startsWith('profile_$userId'))
          .toList();

      // Eliminar cada archivo
      for (var file in userFiles) {
        await _supabase.storage.from('profile-photos').remove([file.name]);
      }

      // Actualizar perfil
      await _supabase.from('profiles').update({
        'photo_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Error al eliminar la foto: $e');
    }
  }
}
