import 'package:shared_preferences/shared_preferences.dart';

class SupabaseConfig {
  // Default demo / public test Supabase credentials.
  // Users can easily set their own Supabase URL and Anon Key in App Settings.
  static const String defaultUrl = 'https://xyzcompany.supabase.co';
  static const String defaultAnonKey = 'public-anon-key-placeholder';

  static const String _keyUrl = 'supabase_url';
  static const String _keyAnonKey = 'supabase_anon_key';

  static Future<String> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUrl) ?? defaultUrl;
  }

  static Future<String> getAnonKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAnonKey) ?? defaultAnonKey;
  }

  static Future<void> saveCredentials(String url, String anonKey) async {
    final prefs = await SharedPreferences.getInstance();
    String cleanUrl = url.trim();
    if (cleanUrl.isNotEmpty && !cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }
    await prefs.setString(_keyUrl, cleanUrl);
    await prefs.setString(_keyAnonKey, anonKey.trim());
  }

  static bool isConfigured(String url, String anonKey) {
    return url.isNotEmpty &&
        anonKey.isNotEmpty &&
        url != defaultUrl &&
        anonKey != defaultAnonKey &&
        url.startsWith('https://');
  }
}
