import 'package:flutter_test/flutter_test.dart';
import 'package:joinme/models/chat_message.dart';
import 'package:joinme/models/sync_event.dart';
import 'package:joinme/models/track.dart';

void main() {
  group('Track Model Tests', () {
    test('Track correctly formats duration in minutes and seconds', () {
      final track = Track(
        id: 'test-1',
        title: 'Song A',
        artist: 'Artist A',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        duration: const Duration(minutes: 3, seconds: 45),
      );

      expect(track.formattedDuration, '3:45');
    });

    test('Track correctly formats long duration with hours', () {
      final track = Track(
        id: 'test-2',
        title: 'Long Mix',
        artist: 'Artist B',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        duration: const Duration(hours: 1, minutes: 15, seconds: 6),
      );

      expect(track.formattedDuration, '1:15:06');
    });

    test('Track toJson and fromJson preserve all fields', () {
      final original = Track(
        id: 'xyz123',
        title: 'Cyberpunk Synth',
        artist: 'Synth Master',
        thumbnailUrl: 'https://example.com/cyber.jpg',
        duration: const Duration(minutes: 4, seconds: 20),
        audioStreamUrl: 'https://stream.example.com/audio.mp4',
        addedBy: 'Alice',
      );

      final json = original.toJson();
      final reconstructed = Track.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.artist, original.artist);
      expect(reconstructed.duration, original.duration);
      expect(reconstructed.audioStreamUrl, original.audioStreamUrl);
      expect(reconstructed.addedBy, original.addedBy);
    });
  });

  group('ChatMessage Model Tests', () {
    test('ChatMessage computes isMe correctly based on currentUserId', () {
      final json = {
        'id': 'msg-1',
        'senderId': 'user-123',
        'senderName': 'Alice',
        'message': 'Love this track!',
        'timestamp': 1700000000000,
      };

      final msgFromMe = ChatMessage.fromJson(json, currentUserId: 'user-123');
      final msgFromOther = ChatMessage.fromJson(json, currentUserId: 'user-456');

      expect(msgFromMe.isMe, isTrue);
      expect(msgFromOther.isMe, isFalse);
      expect(msgFromMe.message, 'Love this track!');
    });
  });

  group('SyncEvent Model Tests', () {
    test('SyncEvent preserves payload and type in serialization', () {
      final event = SyncEvent(
        type: SyncEvent.typeSeek,
        senderId: 'user-abc',
        timestamp: 1730000000000,
        payload: {'positionMs': 45000},
      );

      final json = event.toJson();
      final restored = SyncEvent.fromJson(json);

      expect(restored.type, SyncEvent.typeSeek);
      expect(restored.senderId, 'user-abc');
      expect(restored.timestamp, 1730000000000);
      expect(restored.payload['positionMs'], 45000);
    });
  });
}
