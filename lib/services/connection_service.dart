import 'package:supabase_flutter/supabase_flutter.dart';

enum ConnectionStatus {
  interested,    // Usuario mostró interés
  matched,        // Match mutuo
  chatEnabled,    // Chat habilitado
  visitScheduled, // Visita agendada
  accepted,       // Decisión positiva
  rejected,       // Decisión negativa
}

class ConnectionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Show interest in an apartment/user
  Future<void> showInterest(String apartmentId, String ownerId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Verificar si ya existe un interés
    final existing = await _supabase
        .from('interests')
        .select()
        .eq('user_id', userId)
        .eq('apartment_id', apartmentId)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('interests').insert({
        'user_id': userId,
        'apartment_id': apartmentId,
        'owner_id': ownerId,
        'status': ConnectionStatus.interested.toString(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Check if there's a mutual match
  Future<bool> checkMutualMatch(String apartmentId, String ownerId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    // Verificar si el dueño también mostró interés en el usuario
    final ownerInterest = await _supabase
        .from('interests')
        .select()
        .eq('user_id', ownerId)
        .eq('apartment_id', apartmentId)
        .maybeSingle();

    final userInterest = await _supabase
        .from('interests')
        .select()
        .eq('user_id', userId)
        .eq('apartment_id', apartmentId)
        .maybeSingle();

    if (ownerInterest != null && userInterest != null) {
      // Hay match mutuo
      await _createMatch(userId, ownerId, apartmentId);
      return true;
    }

    return false;
  }

  // Create a match
  Future<void> _createMatch(String userId1, String userId2, String apartmentId) async {
    // Verificar si ya existe el match
    final existing = await _supabase
        .from('matches')
        .select()
        .eq('user1_id', userId1)
        .eq('user2_id', userId2)
        .eq('apartment_id', apartmentId)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('matches').insert({
        'user1_id': userId1,
        'user2_id': userId2,
        'apartment_id': apartmentId,
        'status': ConnectionStatus.matched.toString(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Crear chat automáticamente
      await _createChat(userId1, userId2, apartmentId);
    }
  }

  // Create chat for matched users
  Future<String> _createChat(String userId1, String userId2, String apartmentId) async {
    // Verificar si ya existe el chat
    final existing = await _supabase
        .from('chats')
        .select()
        .or('(user1_id.eq.$userId1,user2_id.eq.$userId1)')
        .or('(user1_id.eq.$userId2,user2_id.eq.$userId2)')
        .eq('apartment_id', apartmentId)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final response = await _supabase.from('chats').insert({
      'user1_id': userId1,
      'user2_id': userId2,
      'apartment_id': apartmentId,
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    return response['id'] as String;
  }

  // Schedule a visit
  Future<void> scheduleVisit(String chatId, DateTime visitDate, String? notes) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('visits').insert({
      'chat_id': chatId,
      'scheduled_by': userId,
      'visit_date': visitDate.toIso8601String(),
      'notes': notes,
      'status': 'scheduled',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Actualizar status del match
    await _updateMatchStatus(chatId, ConnectionStatus.visitScheduled);
  }

  // Make a decision (accept or reject)
  Future<void> makeDecision(String chatId, bool accepted) async {
    final status = accepted 
        ? ConnectionStatus.accepted 
        : ConnectionStatus.rejected;

    await _updateMatchStatus(chatId, status);
  }

  // Update match status
  Future<void> _updateMatchStatus(String chatId, ConnectionStatus status) async {
    final chat = await _supabase
        .from('chats')
        .select('id, user1_id, user2_id, apartment_id')
        .eq('id', chatId)
        .single();

    await _supabase.from('matches').update({
      'status': status.toString(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('apartment_id', chat['apartment_id'] as String);
  }

  // Get user's matches
  Future<List<Map<String, dynamic>>> getUserMatches() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('matches')
        .select('''
          *,
          user1:profiles!matches_user1_id_fkey(*),
          user2:profiles!matches_user2_id_fkey(*),
          apartment:apartments(*)
        ''')
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get user's interests
  Future<List<Map<String, dynamic>>> getUserInterests() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('interests')
        .select('''
          *,
          apartment:apartments(*),
          owner:profiles!interests_owner_id_fkey(*)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
