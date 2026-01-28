import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class MatchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Registra un swipe (like o dislike) en la base de datos
  Future<void> recordSwipe({
    required String apartmentId,
    required String ownerId,
    required String type, // 'like' or 'dislike'
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      await _supabase.from('swipes').insert({
        'user_id': user.id,
        'apartment_id': apartmentId,
        'owner_id': ownerId,
        'type': type,
      });
    } catch (e) {
      if (e.toString().contains('duplicate key')) return;
      rethrow;
    }
  }

  /// Cuenta cuántos swipes ha hecho el usuario en las últimas 24 horas
  Future<int> getDailySwipeCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final yesterday = DateTime.now().subtract(const Duration(hours: 24));

    final count = await _supabase
        .from('swipes')
        .count(CountOption.exact)
        .eq('user_id', user.id)
        .gte('created_at', yesterday.toIso8601String());

    return count;
  }

  /// Obtiene los IDs de departamentos ya "swipeados" para no mostrarlos de nuevo
  Future<List<String>> getSwipedApartmentIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('swipes')
        .select('apartment_id')
        .eq('user_id', user.id);

    return (response as List).map((e) => e['apartment_id'] as String).toList();
  }

  /// Obtiene los likes recibidos por el usuario actual (Dueño)
  Future<List<Map<String, dynamic>>> getIncomingLikes() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      // 1. Fetch swipes where owner_id = me and type = like
      final swipesRes = await _supabase
          .from('swipes')
          .select('*, apartments(*)')
          .eq('owner_id', user.id)
          .eq('type', 'like');

      final swipes = List<Map<String, dynamic>>.from(swipesRes);

      if (swipes.isEmpty) return [];

      // 2. Extract unique user IDs of the "likers"
      final userIds =
          swipes.map((e) => e['user_id'] as String).toSet().toList();

      // 3. Fetch profiles for these users manually
      final profilesRes =
          await _supabase.from('profiles').select().filter('id', 'in', userIds);

      final profiles = List<Map<String, dynamic>>.from(profilesRes);

      // 4. Merge profiles into swipes
      final profileMap = {for (var p in profiles) p['id']: p};

      final result = swipes.map((swipe) {
        final userId = swipe['user_id'];
        final profile = profileMap[userId];

        return {
          ...swipe,
          'profiles': profile,
        };
      }).toList();

      return result;
    } catch (e) {
      debugPrint('Error getting incoming likes: $e');
      return [];
    }
  }

  /// Acepta un match: Crea el chat y elimina el swipe pendiente
  Future<String> acceptMatch({
    required String swipeId,
    required String otherUserId,
    required String apartmentId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    // 1. Crear conversación
    // Generamos el ID en el cliente para evitar problemas de RLS al hacer select()
    // antes de ser participante.
    final chatId = const Uuid().v4();

    await _supabase.from('chats').insert({
      'id': chatId,
      'created_at': DateTime.now().toIso8601String(),
      'user1_id': user.id,
      'user2_id': otherUserId,
      'apartment_id': apartmentId,
    });

    // 2. Agregar participantes
    await _supabase.from('chat_participants').insert([
      {'chat_id': chatId, 'user_id': user.id},
      {'chat_id': chatId, 'user_id': otherUserId}
    ]);

    // 3. Eliminar swipe
    await _supabase.from('swipes').delete().eq('id', swipeId);

    return chatId;
  }

  /// Rechaza un match
  Future<void> rejectMatch(String swipeId) async {
    await _supabase.from('swipes').delete().eq('id', swipeId);
  }

  /// Cancela un like enviado (antes de que sea aceptado)
  Future<void> cancelSentLike(String swipeId) async {
    await _supabase.from('swipes').delete().eq('id', swipeId);
  }

  /// Obtiene los likes enviados por el usuario actual (Solicitudes pendientes)
  Future<List<Map<String, dynamic>>> getSentLikes() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      // 1. Fetch swipes where user_id = me and type = like
      final swipesRes = await _supabase
          .from('swipes')
          .select()
          .eq('user_id', user.id)
          .eq('type', 'like');

      final swipes = List<Map<String, dynamic>>.from(swipesRes);
      if (swipes.isEmpty) return [];

      // 2. Extract IDs
      final apartmentIds =
          swipes.map((e) => e['apartment_id'] as String).toSet().toList();
      final ownerIds =
          swipes.map((e) => e['owner_id'] as String).toSet().toList();

      // 3. Fetch Apartments
      final apartmentsRes = await _supabase
          .from('apartments')
          .select()
          .filter('id', 'in', apartmentIds);
      final apartments = List<Map<String, dynamic>>.from(apartmentsRes);
      final aptMap = {for (var a in apartments) a['id']: a};

      // 4. Fetch Owner Profiles
      final profilesRes = await _supabase
          .from('profiles')
          .select()
          .filter('id', 'in', ownerIds);
      final profiles = List<Map<String, dynamic>>.from(profilesRes);
      final profileMap = {for (var p in profiles) p['id']: p};

      // 5. Merge
      final result = swipes.map((swipe) {
        final aptId = swipe['apartment_id'];
        final ownerId = swipe['owner_id'];

        return {
          ...swipe,
          'apartments': aptMap[aptId],
          'profiles': profileMap[ownerId], // Owner profile
        };
      }).toList();

      return result;
    } catch (e) {
      debugPrint('Error getting sent likes: $e');
      return [];
    }
  }
}
