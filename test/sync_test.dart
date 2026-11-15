import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joinme/config/supabase_config.dart';
import 'package:joinme/models/sync_event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseConfig Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isConfigured returns false for default or empty credentials', () {
      expect(
        SupabaseConfig.isConfigured(
          SupabaseConfig.defaultUrl,
          SupabaseConfig.defaultAnonKey,
        ),
        isFalse,
      );

      expect(
        SupabaseConfig.isConfigured('', ''),
        isFalse,
      );
    });

    test('isConfigured returns true for valid custom HTTPS credentials', () {
      expect(
        SupabaseConfig.isConfigured(
          'https://my-real-project.supabase.co',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.validkey',
        ),
        isTrue,
      );
    });

    test('saveCredentials automatically prepends https if missing', () async {
      await SupabaseConfig.saveCredentials(
        'myproject.supabase.co',
        'my-anon-key',
      );

      final savedUrl = await SupabaseConfig.getUrl();
      final savedKey = await SupabaseConfig.getAnonKey();

      expect(savedUrl, 'https://myproject.supabase.co');
      expect(savedKey, 'my-anon-key');
    });
  });

  group('SyncEvent Signaling Tests', () {
    test('All SyncEvent signaling types serialize properly', () {
      final types = [
        SyncEvent.typePlay,
        SyncEvent.typePause,
        SyncEvent.typeSeek,
        SyncEvent.typeTrackChange,
        SyncEvent.typeQueueAdd,
        SyncEvent.typeQueueRemove,
        SyncEvent.typeReaction,
        SyncEvent.typeSyncPing,
        SyncEvent.typeSyncRequest,
        SyncEvent.typeSyncResponse,
        SyncEvent.typeVoiceOffer,
        SyncEvent.typeVoiceAnswer,
        SyncEvent.typeVoiceIce,
        SyncEvent.typeVoiceHangup,
      ];

      for (final type in types) {
        final event = SyncEvent(
          type: type,
          senderId: 'usr-1',
          timestamp: 1000,
          payload: {'k': 'v'},
        );
        final json = event.toJson();
        final reconstructed = SyncEvent.fromJson(json);
        expect(reconstructed.type, type);
        expect(reconstructed.senderId, 'usr-1');
      }
    });
  });
}
