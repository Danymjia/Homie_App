import 'package:flutter/foundation.dart';
import 'package:roomie_app/models/compatibility_question_model.dart';
import 'package:roomie_app/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompatibilityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Save user compatibility answers
  Future<void> saveCompatibilityAnswers(Map<String, String> answers,
      {String? country, String? city}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    print('Saving compatibility answers for user: $userId');
    print('Selected country: $country');
    print('Selected city: $city');

    // Calcular score inicial (se actualizará cuando haya matches)
    final compatibilityData = {
      'habits': answers,
      'overall_score': 0.0,
    };

    // Update profiles table with city, country, and other data
    final updateData = <String, dynamic>{
      'city': city, // Save city separately
      'country': country, // Save country separately
      'compatibility_data': compatibilityData,
      'is_verified': true, // Mark first login as completed
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await _supabase.from('profiles').update(updateData).eq('id', userId);
      print('Profile updated successfully');
    } catch (e) {
      print('Error updating profile: $e');
      print('Error type: ${e.runtimeType}');

      // Try without city and country fields first
      try {
        await _supabase.from('profiles').update({
          'first_login_completed': true,
          'compatibility_data': compatibilityData,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        print('Profile updated without location field');
      } catch (e2) {
        print('Error updating profile without location: $e2');
        rethrow;
      }
    }
  }

  // Get compatibility answers for a user
  Future<Map<String, dynamic>?> getCompatibilityAnswers(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('compatibility_data')
          .eq('id', userId)
          .single();

      return response['compatibility_data'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Calculate match score between two users
  Future<double> calculateMatchScore(String userId1, String userId2) async {
    final answers1 = await getCompatibilityAnswers(userId1);
    final answers2 = await getCompatibilityAnswers(userId2);

    if (answers1 == null || answers2 == null) return 0.0;

    final habits1 = answers1['habits'] as Map<String, dynamic>? ?? {};
    final habits2 = answers2['habits'] as Map<String, dynamic>? ?? {};

    return CompatibilityScore.calculateMatchScore(habits1, habits2);
  }

  // Get compatible users based on score threshold
  Future<List<Map<String, dynamic>>> getCompatibleUsers({
    double minScore = 70.0,
    int limit = 50,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Obtener todos los usuarios con respuestas de compatibilidad
    final response = await _supabase
        .from('profiles')
        .select()
        .neq('id', userId)
        .not('compatibility_data', 'is', null)
        .limit(limit);

    final List<Map<String, dynamic>> compatibleUsers = [];

    for (var user in response) {
      final score = await calculateMatchScore(userId, user['id'] as String);
      if (score >= minScore) {
        compatibleUsers.add({
          ...user,
          'match_score': score,
        });
      }
    }

    // Ordenar por score descendente
    compatibleUsers.sort((a, b) =>
        (b['match_score'] as double).compareTo(a['match_score'] as double));

    return compatibleUsers;
  }
}
