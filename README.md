# 🎵 JoinMe - Synchronized Music Listening & Social Sharing App

**JoinMe** is a modern Flutter-based mobile application designed for two people to **listen to the exact same music simultaneously in real-time**, no matter the distance. It features real-time YouTube music streaming, low-latency synchronization, collaborative playlist queueing, live floating emoji reaction bursts, and synchronized WebRTC voice chat.

JoinMe is cross-platform and natively ready for both **iOS (Xcode / Runner.xcworkspace)** and **Android (Gradle)**.

---

## 🌟 Key Features

1. **YouTube Music Streaming & Search (`youtube_explode_dart` + `just_audio`):**
   - Instant search across millions of YouTube tracks and artists without API keys or quotas.
   - Direct high-bitrate audio streaming extraction.
   - Background audio playback and lockscreen playback controls.

2. **Low-Latency Supabase Realtime Synchronization:**
   - **Room System:** Unique 6-character room codes (e.g., `JM-8492`).
   - **Millisecond Precision Sync:** Play, Pause, and Seek events calculate and offset network latency using client timestamps: $expectedPosition = reportedPosition + (now - eventTimestamp)$.
   - **Heartbeat Drift Correction:** Host periodically pings playback position. If clock drift exceeds tolerance, the guest seamlessly aligns.
   - **Local / Demo Mode:** Runs immediately out-of-the-box in simulated mode if Supabase credentials have not been entered yet.

3. **Collaborative Queue:**
   - Both users can search and append songs to the shared playlist or remove songs.
   - Auto-plays the next queued track for both users simultaneously when the current song finishes.

4. **WebRTC Real-time Voice Chat:**
   - Crystal-clear peer-to-peer voice conversation while music plays in the background.
   - One-tap Microphone Mute/Unmute toggle and End Call control.
   - Signaling (SDP Offer/Answer/ICE candidates) exchanged over the Supabase Realtime broadcast channel.

5. **Live Floating Emoji Reaction Bursts:**
   - Tap ❤️, 🔥, 🎵, 👏, 🥳, or 💃 to launch animated floating reaction bursts visible on both screens at the exact same moment.

6. **Animated Audio Visualizer:**
   - Dynamic neon audio wave bars that react dynamically to music playback.

7. **In-Room Real-time Chat:**
   - Dedicated slide-up chat sheet with instant messaging and message bubbles.

---

## 📂 Project Structure

```
lib/
├── config/
│   ├── supabase_config.dart   # Supabase URL & Anon Key configuration
│   └── theme.dart             # Dark modern theme, neon gradients & typography
├── models/
│   ├── chat_message.dart      # Real-time chat message data model
│   ├── sync_event.dart        # Real-time broadcast sync event model
│   └── track.dart             # YouTube audio track & stream model
├── services/
│   ├── audio_player_service.dart # just_audio wrapper & latency compensation
│   ├── supabase_sync_service.dart# Supabase Realtime Broadcast & Presence service
│   ├── webrtc_service.dart       # P2P voice call service
│   └── youtube_service.dart      # YouTube search & audio stream extractor
├── providers/
│   └── room_provider.dart     # ChangeNotifier state manager (Sync, Player, Queue, WebRTC)
├── widgets/
│   ├── audio_visualizer.dart  # Animated equalizer wave visualizer
│   ├── chat_sheet.dart        # In-room messaging bottom sheet
│   ├── emoji_burst_overlay.dart# Floating emoji reaction animations
│   ├── queue_sheet.dart       # Collaborative playlist bottom sheet
│   └── voice_call_bar.dart    # Voice chat status & mic toggle bar
├── screens/
│   ├── home_screen.dart       # Room creation & joining home screen
│   ├── room_screen.dart       # Vinyl player, visualizer, playback controls & reactions
│   ├── search_screen.dart     # YouTube music search screen
│   └── settings_screen.dart   # Supabase credentials configuration screen
└── main.dart                  # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x+ (Dart 3.x+)
- Android Studio / Android SDK (for Android builds)
- macOS & Xcode (for iOS builds)

### Install Dependencies
```bash
flutter pub get
```

### Run on Android
```bash
flutter run -d android
```

### Run on iOS (Xcode)
1. Navigate to the `ios` directory and install CocoaPods pods:
   ```bash
   cd ios
   pod install
   cd ..
   ```
2. Open the Xcode workspace:
   ```bash
   open ios/Runner.xcworkspace
   ```
   *(Always open Runner.xcworkspace rather than Runner.xcodeproj).*
3. Run via Flutter CLI:
   ```bash
   flutter run -d ios
   ```

---

## ⚙️ Supabase Configuration

The application works immediately in local demo mode without configuration. For live real-time sync across two separate devices:

1. Create a free project at [supabase.com](https://supabase.com).
2. Go to **Project Settings > API** and copy:
   - **Project URL**
   - **Anon / Public Key**
3. Open the app, tap the **Settings (gear)** icon on the top right, paste your credentials, and tap **Save Configuration**.

---

## 📱 Platform Permissions

- **Android (`AndroidManifest.xml`):**
  - Configured with `INTERNET`, `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, and `FOREGROUND_SERVICE_MEDIA_PLAYBACK`.
- **iOS (`Info.plist` & `Podfile`):**
  - Configured with `NSMicrophoneUsageDescription` (Microphone permission for voice chat).
  - Background audio & VoIP modes enabled (`UIBackgroundModes: audio, voip`).
  - Target iOS Deployment Version: `13.0`.

---

## 🧪 Testing & Analysis

To verify code quality and run tests:
```bash
flutter analyze
flutter test
```

---

## 📖 Documentation & Security

- **[GitHub Wiki](https://github.com/JennyDarling/joinme/wiki)**: Full guides on Architecture, WebRTC voice calling, Supabase setup, and platform deployment.
- **[Security Policy](SECURITY.md)**: Supported versions, vulnerability reporting guidelines, and end-to-end encryption specs.

