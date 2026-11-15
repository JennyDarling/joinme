import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import '../config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _anonKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  void _loadCredentials() async {
    final url = await SupabaseConfig.getUrl();
    final anonKey = await SupabaseConfig.getAnonKey();
    setState(() {
      _urlController.text = url;
      _anonKeyController.text = anonKey;
    });
  }

  void _saveCredentials() async {
    await SupabaseConfig.saveCredentials(
      _urlController.text,
      _anonKeyController.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supabase configuration saved successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Sync'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Supabase Realtime Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.darkCardGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Supabase Realtime Infrastructure',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'JoinMe uses Supabase Realtime Broadcast and Presence channels so both listeners stay in sync down to the millisecond.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'SUPABASE PROJECT CREDENTIALS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),

          // URL field
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Supabase Project URL',
              hintText: 'https://xyzcompany.supabase.co',
              prefixIcon: Icon(Icons.link_rounded),
            ),
          ),
          const SizedBox(height: 14),

          // Anon Key field
          TextField(
            controller: _anonKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Supabase Anon / Publishable Key',
              hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
              prefixIcon: Icon(Icons.key_rounded),
            ),
          ),
          const SizedBox(height: 20),

          // Save button
          ElevatedButton.icon(
            onPressed: _saveCredentials,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Configuration'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 28),

          // Instructions Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 How to Connect Your Supabase Project',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Create a free project at supabase.com.\n'
                  '2. Navigate to Project Settings > API to get your Project URL and anon key.\n'
                  '3. Paste them into the fields above and press Save.\n'
                  '4. JoinMe will instantly connect to your realtime rooms with live presence.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
