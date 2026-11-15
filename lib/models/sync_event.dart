class SyncEvent {
  static const String typePlay = 'play';
  static const String typePause = 'pause';
  static const String typeSeek = 'seek';
  static const String typeTrackChange = 'track_change';
  static const String typeQueueAdd = 'queue_add';
  static const String typeQueueRemove = 'queue_remove';
  static const String typeReaction = 'reaction';
  static const String typeVoiceOffer = 'voice_offer';
  static const String typeVoiceAnswer = 'voice_answer';
  static const String typeVoiceIce = 'voice_ice';
  static const String typeVoiceHangup = 'voice_hangup';
  static const String typeSyncPing = 'sync_ping';
  static const String typeSyncRequest = 'sync_request';
  static const String typeSyncResponse = 'sync_response';

  final String type;
  final String senderId;
  final int timestamp; // epoch milliseconds
  final Map<String, dynamic> payload;

  SyncEvent({
    required this.type,
    required this.senderId,
    required this.timestamp,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'senderId': senderId,
      'timestamp': timestamp,
      'payload': payload,
    };
  }

  factory SyncEvent.fromJson(Map<String, dynamic> json) {
    return SyncEvent(
      type: json['type'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
    );
  }
}
