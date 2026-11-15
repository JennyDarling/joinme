import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joinme/config/supabase_config.dart';

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
}
