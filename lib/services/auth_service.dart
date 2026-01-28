import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomie_app/models/user_profile_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Sign in with email and password (simple version)
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with email and password (with confirmation check)
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Verificar si el correo está confirmado
      if (response.user != null) {
        final userConfirmed = await _isEmailConfirmed(response.user!.id);

        if (!userConfirmed) {
          // Cerrar sesión si el correo no está confirmado
          await _supabase.auth.signOut();
          throw Exception(
              'Por favor, confirma tu correo electrónico antes de iniciar sesión. ' +
                  'Revisa tu bandeja de entrada y haz clic en el enlace de confirmación.');
        }
      }

      return response;
    } catch (e) {
      debugPrint('Error in AuthService.signIn: $e');

      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Correo electrónico o contraseña incorrectos.');
      } else if (e.toString().contains('Email not confirmed')) {
        throw Exception(
            'Por favor, confirma tu correo electrónico antes de iniciar sesión. ' +
                'Revisa tu bandeja de entrada y haz clic en el enlace de confirmación.');
      } else {
        throw Exception(
            'Error al iniciar sesión. Por favor, intenta nuevamente.');
      }
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required UserType userType,
    String? verificationDocumentUrl,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'age': age,
          'user_type': userType.toString(),
          'verification_document_url': verificationDocumentUrl,
          'is_verified': false, // Requiere verificación manual
        },
      );

      if (response.user != null) {
        // Crear perfil en la tabla profiles
        await _createUserProfile(response.user!, fullName, age, userType);

        // Mensaje de éxito (incluso si hay error con el correo)
        debugPrint('Usuario creado exitosamente: ${response.user!.email}');
        debugPrint('Correo de confirmación enviado');
      }

      return response;
    } catch (e) {
      debugPrint('Error in AuthService.signUp: $e');

      // Re-throw with more specific error messages
      if (e.toString().contains('user_already_exists') ||
          e.toString().contains('User already registered')) {
        throw Exception(
            'Este correo electrónico ya está registrado. Intenta iniciar sesión o usa otro correo.');
      } else if (e.toString().contains('weak_password')) {
        throw Exception(
            'La contraseña es demasiado débil. Debe tener al menos 8 caracteres.');
      } else if (e.toString().contains('invalid_email')) {
        throw Exception('El correo electrónico no es válido.');
      } else if (e.toString().contains('unexpected_failure') &&
          e.toString().contains('Error sending confirmation email')) {
        throw Exception(
            'Cuenta creada exitosamente pero hubo un error al enviar el correo de confirmación. ' +
                'Tu cuenta está activa en la base de datos. ' +
                'Por favor, intenta iniciar sesión directamente.');
      } else {
        throw Exception(
            'Error al crear la cuenta. Por favor, intenta nuevamente.');
      }
    }
  }

  // Sign in with social provider
  Future<bool> signInWithProvider(OAuthProvider provider) async {
    try {
      await _supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'roomieapp://login-callback',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    // Apuntar a la URL de la web desplegada
    // IMPORTANTE: Asegúrate que esta URL esté en la lista de Redirect URLs de Supabase
    const webRedirectUrl =
        'https://elaborate-stardust-b3cead.netlify.app/reset-password';
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: webRedirectUrl,
    );
  }

  // Check if email is confirmed
  Future<bool> _isEmailConfirmed(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('is_verified')
          .eq('id', userId)
          .single();

      return response['is_verified'] ?? false;
    } catch (e) {
      debugPrint('Error checking email confirmation: $e');
      return false;
    }
  }

  // Create user profile in profiles table
  Future<void> _createUserProfile(
    User user,
    String fullName,
    int age,
    UserType userType,
  ) async {
    await _supabase.from('profiles').insert({
      'id': user.id,
      'email': user.email,
      'full_name': fullName,
      'age': age,
      'user_type': userType.toString(),
      'is_verified': false,
      'lifestyle_tags': [],
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get user profile
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('profiles').update({
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Upload verification document
  Future<String?> uploadVerificationDocument(String filePath) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final fileName =
        'verification_${userId}_${DateTime.now().millisecondsSinceEpoch}';

    // Leer el archivo como bytes
    final fileBytes = await File(filePath).readAsBytes();

    await _supabase.storage
        .from('verification-documents')
        .uploadBinary(fileName, fileBytes);

    return _supabase.storage
        .from('verification-documents')
        .getPublicUrl(fileName);
  }
}
