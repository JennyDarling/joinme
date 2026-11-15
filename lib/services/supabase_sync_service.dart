import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/chat_message.dart';
import '../models/sync_event.dart';

class SupabaseSyncService {
  RealtimeChannel? _channel;
  bool _isInitialized = false;
  bool _isConfigured = false;

  final _eventController = StreamController<SyncEvent>.broadcast();
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _peerPresenceController = StreamController<bool>.broadcast();

  Stream<SyncEvent> get onSyncEvent => _eventController.stream;
  Stream<ChatMessage> get onChatMessage => _messageController.stream;
  Stream<bool> get onPeerPresence => _peerPresenceController.stream;

  bool get isConfigured => _isConfigured;

  Future<void> initialize({bool force = false}) async {
    if (_isInitialized && !force) return;
    try {
      final url = await SupabaseConfig.getUrl();
      final anonKey = await SupabaseConfig.getAnonKey();

      if (SupabaseConfig.isConfigured(url, anonKey)) {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
        );
        _isConfigured = true;
      } else {
        _isConfigured = false;
      }
      _isInitialized = true;
    } catch (e) {
      _isConfigured = false;
      _isInitialized = true;
    }
  }

  Future<void> joinRoom({
    required String roomCode,
    required String userId,
    required String userName,
    required bool isHost,
  }) async {
    if (!_isConfigured) {
      // In demo / unconfigured mode: simulate peer presence after 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (!_peerPresenceController.isClosed) {
          _peerPresenceController.add(true);
        }
      });
      return;
    }

    try {
      final client = Supabase.instance.client;
      final channelName = 'joinme:room:$roomCode';
      _channel = client.channel(channelName);

      // Listen for sync broadcast events
      _channel!.onBroadcast(
        event: 'sync_event',
        callback: (payload) {
          try {
            final event = SyncEvent.fromJson(Map<String, dynamic>.from(payload));
            if (event.senderId != userId) {
              _eventController.add(event);
            }
          } catch (_) {}
        },
      );

      // Listen for chat messages
      _channel!.onBroadcast(
        event: 'chat_message',
        callback: (payload) {
          try {
            final msg = ChatMessage.fromJson(
              Map<String, dynamic>.from(payload),
              currentUserId: userId,
            );
            _messageController.add(msg);
          } catch (_) {}
        },
      );

      // Listen for presence
      _channel!.onPresenceSync((_) {
        final state = _channel!.presenceState();
        final joinedCount = state.length;
        _peerPresenceController.add(joinedCount > 1);
      });

      _channel!.subscribe();

      // Track presence
      await _channel!.track({
        'user_id': userId,
        'user_name': userName,
        'is_host': isHost,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Fallback
      _peerPresenceController.add(true);
    }
  }

  Future<void> sendSyncEvent(SyncEvent event) async {
    if (_channel != null && _isConfigured) {
      try {
        await _channel!.sendBroadcastMessage(
          event: 'sync_event',
          payload: event.toJson(),
        );
      } catch (_) {}
    }
  }

  Future<void> sendChatMessage(ChatMessage message) async {
    // Add locally first
    _messageController.add(message);

    if (_channel != null && _isConfigured) {
      try {
        await _channel!.sendBroadcastMessage(
          event: 'chat_message',
          payload: message.toJson(),
        );
      } catch (_) {}
    }
  }

  Future<void> leaveRoom() async {
    if (_channel != null) {
      try {
        await _channel!.unsubscribe();
      } catch (_) {}
      _channel = null;
    }
  }

  void dispose() {
    leaveRoom();
    _eventController.close();
    _messageController.close();
    _peerPresenceController.close();
  }
}
