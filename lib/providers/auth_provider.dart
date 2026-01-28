import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> checkPremiumStatus() async {
    final user = currentUser;
    if (user == null) return;
    try {
      final data = await _supabase
          .from('profiles')
          .select('is_premium')
          .eq('id', user.id)
          .single();
      _isPremium = data['is_premium'] ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking premium status: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await checkPremiumStatus();
      }
      notifyListeners();
      return response.user != null;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return false;
    }
  }

  Future<bool> signUp(
      String email, String password, String fullName, int age) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'age': age,
        },
      );
      notifyListeners();
      return response.user != null;
    } catch (e) {
      debugPrint('Error signing up: $e');

      // Check for specific error types
      if (e.toString().contains('user_already_exists') ||
          e.toString().contains('User already registered')) {
        throw Exception(
            'Este correo electrónico ya está registrado. Intenta iniciar sesión o usa otro correo.');
      } else if (e.toString().contains('weak_password')) {
        throw Exception(
            'La contraseña es demasiado débil. Debe tener al menos 8 caracteres.');
      } else if (e.toString().contains('invalid_email')) {
        throw Exception('El correo electrónico no es válido.');
      } else {
        throw Exception(
            'Error al crear la cuenta. Por favor, intenta nuevamente.');
      }
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }
}
