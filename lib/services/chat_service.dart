import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener conversaciones del usuario actual con detalles del otro participante
  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = _supabase.auth.currentUser!.id;

    // 1. Obtener chats donde participo
    final myChatsRes = await _supabase
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);

    final List<String> chatIds =
        (myChatsRes as List).map((e) => e['chat_id'] as String).toList();

    if (chatIds.isEmpty) return [];

    // 2. Obtener los "otros" participantes de esos chats
    final participantsRes = await _supabase
        .from('chat_participants')
        .select('chat_id, user_id')
        .filter('chat_id', 'in', chatIds)
        .neq('user_id', userId);

    final participants = List<Map<String, dynamic>>.from(participantsRes);
    if (participants.isEmpty) return [];

    // 3. Obtener perfiles de esos usuarios
    final otherUserIds =
        participants.map((e) => e['user_id'] as String).toSet().toList();

    final profilesRes = await _supabase
        .from('profiles')
        .select('id, full_name, photo_url')
        .filter('id', 'in', otherUserIds);

    final profilesMap = {for (var p in profilesRes) p['id']: p};

    // 4. Combinar todo
    final result = participants.map((p) {
      final pUserId = p['user_id'];
      final profile = profilesMap[pUserId];

      return {
        'chat_id': p['chat_id'],
        'user_id': pUserId,
        'profiles': profile, // Estructura esperada por ChatListScreen
      };
    }).toList();

    return result;
  }

  // Obtener metadatos de un chat (nombre y foto del otro usuario)
  Future<Map<String, dynamic>?> getChatMetadata(String chatId) async {
    final userId = _supabase.auth.currentUser!.id;

    try {
      // 1. Buscar al otro participante
      final participantRes = await _supabase
          .from('chat_participants')
          .select('user_id')
          .eq('chat_id', chatId)
          .neq('user_id', userId)
          .single();

      final otherUserId = participantRes['user_id'];

      // 2. Buscar su perfil
      final profileRes = await _supabase
          .from('profiles')
          .select('full_name, photo_url')
          .eq('id', otherUserId)
          .single();

      return profileRes;
    } catch (e) {
      return null;
    }
  }

  // Obtener mensajes de un chat específico
  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true); // Ascendente para chat UI

    return List<Map<String, dynamic>>.from(response);
  }

  // Enviar un mensaje
  Future<void> sendMessage(String chatId, String content) async {
    final userId = _supabase.auth.currentUser!.id;

    await _supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'text': content,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Opcional: Actualizar el último mensaje en la tabla 'chats'
    /*
    await _supabase.from('chats').update({
      'last_message': content,
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', chatId);
    */
  }

  // Suscribirse a nuevos mensajes en tiempo real
  Stream<List<Map<String, dynamic>>> getMessagesStream(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
  }
}
