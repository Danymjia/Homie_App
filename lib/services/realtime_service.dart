import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomie_app/services/notification_service.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();

  factory RealtimeService() {
    return _instance;
  }

  RealtimeService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();
  bool _isInitialized = false;

  void init(BuildContext context) {
    if (_isInitialized) return;
    _isInitialized = true;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // 1. Listen for new likes (swipes)
    _supabase
        .channel('public:swipes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'swipes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'owner_id',
            value: user.id,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record['type'] == 'like') {
              _notificationService.showNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: '¡Nueva solicitud!',
                body: 'Alguien está interesado en tu habitación.',
              );
            }
          },
        )
        .subscribe();

    // 2. Listen for new matches (chats)
    _supabase
        .channel('public:chats')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chats',
          callback: (payload) {
            final record = payload.newRecord;
            // Check if I am part of this chat
            if (record['user1_id'] == user.id ||
                record['user2_id'] == user.id) {
              _notificationService.showNotification(
                id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1,
                title: '¡Es un Match!',
                body: 'Tienes una nueva conexión. Empieza a chatear.',
              );
            }
          },
        )
        .subscribe();

    debugPrint('RealtimeService initialized for user: ${user.id}');
  }
}
