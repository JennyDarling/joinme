# 🎵 JoinMe - Eşzamanlı Müzik Dinleme & Sosyal Paylaşım Uygulaması

**JoinMe**, iki kullanıcının nerede olurlarsa olsunlar **aynı anda tam aynı saniyede aynı müziği dinlemesini**, eşzamanlı reaksiyonlar göndermesini, ortak çalma sırası oluşturmasını ve arka planda kesintisiz sesli sohbet etmesini sağlayan Flutter tabanlı modern bir mobil uygulamadır.

Hem **iOS (Xcode / Runner.xcworkspace)** hem de **Android (Gradle)** platformlarını eksiksiz destekler.

---

## 🌟 Öne Çıkan Özellikler

1. **YouTube Müzik Akışı & Arama (`youtube_explode_dart` + `just_audio`):**
   - Milyonlarca şarkı ve video arasında anında arama.
   - Doğrudan yüksek kaliteli ses akışı (audio stream).
   - Arka planda çalma (Background audio playback) ve kilit ekranı desteği.

2. **Düşük Gecikmeli Supabase Realtime Senkronizasyonu:**
   - **Oda Sistemi:** 6 karakterli tekil oda kodu (örn: `JM-8492`).
   - **Milisaniye Hassasiyetinde Sync:** Oynat (Play), Duraklat (Pause) ve İleri/Geri Sarma (Seek) eylemlerinde istemciler arası ağ gecikmesi ($position + (now - timestamp)$ formülüyle) telafi edilir.
   - **Periyodik Kalp Atışı (Heartbeat Sync):** Oynatma sırasında olası saat kaymaları otomatik olarak düzeltilir.

3. **Ortak Çalma Sırası (Collaborative Queue):**
   - Her iki kullanıcı da sıraya yeni YouTube parçaları ekleyebilir veya parçaları sıradan çıkarabilir.
   - Şarkı bittiğinde sıradaki parça her iki cihazda eşzamanlı olarak başlar.

4. **WebRTC Eşzamanlı Sesli Sohbet:**
   - Müzik çalarken arkadaşınızla canlı konuşabilme.
   - Tek dokunuşla mikrofonu sessize alma (Mute/Unmute) ve çağrıyı sonlandırma.
   - Supabase Realtime kanalı üzerinden güvenli P2P sinyalleşme (SDP Offer/Answer/ICE).

5. **Canlı Reaksiyon Patlamaları (Live Emoji Bursts):**
   - Müzik ritmine göre ❤️, 🔥, 🎵, 👏, 🥳, 💃 butonlarına dokunulduğunda her iki ekranda aynı anda yükselen süzülen emojiler.

6. **Dinamik Ses Dalgası (Audio Visualizer):**
   - Çalan müziğe göre hareketlenen neon ekolayzır dalgaları.

7. **Oda İçi Anlık Sohbet:**
   - Şarkı dinlerken eşzamanlı mesajlaşma paneli.

---

## 📂 Proje Mimarisi

```
lib/
├── config/
│   ├── supabase_config.dart   # Supabase URL & Anon Key ayarları
│   └── theme.dart             # Modern koyu tema, neon gradyanlar ve tipografi
├── models/
│   ├── chat_message.dart      # Sohbet mesajı veri modeli
│   ├── sync_event.dart        # Realtime senkronizasyon olayları (play/pause/seek/webrtc)
│   └── track.dart             # YouTube müzik parçası ve akış modeli
├── services/
│   ├── audio_player_service.dart # just_audio wrapper ve gecikme telafi algoritması
│   ├── supabase_sync_service.dart# Supabase Realtime Broadcast & Presence servisi
│   ├── webrtc_service.dart       # P2P sesli arama servisi
│   └── youtube_service.dart      # YouTube arama ve ses akışı ayrıştırıcı
├── providers/
│   └── room_provider.dart     # Tüm oda durumunu, çaları ve senkronizasyonu yöneten ChangeNotifier
├── widgets/
│   ├── audio_visualizer.dart  # Hareketli ekolayzır dalga görselleştirici
│   ├── chat_sheet.dart        # Oda içi mesajlaşma alt penceresi
│   ├── emoji_burst_overlay.dart# Ekranda süzülen reaksiyon animasyonları
│   ├── queue_sheet.dart       # Ortak çalma sırası alt penceresi
│   └── voice_call_bar.dart    # Sesli sohbet durum ve kontrol çubuğu
├── screens/
│   ├── home_screen.dart       # Giriş, Oda Açma ve Odaya Katılma ekranı
│   ├── room_screen.dart       # Dönen vinil plak, müzik çalar ve kontroller
│   ├── search_screen.dart     # YouTube müzik arama ekranı
│   └── settings_screen.dart   # Supabase bağlantı ve yapılandırma ekranı
└── main.dart                  # Uygulama başlangıç noktası
```

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter 3.x+ (Dart 3.x+)
- Android Studio / Android SDK (Android için)
- macOS & Xcode (iOS için)

### Bağımlılıkları Yükleme
```bash
flutter pub get
```

### Android'de Çalıştırma
```bash
flutter run -d android
```

### iOS / Xcode'da Çalıştırma
1. `ios` klasörüne gidip CocoaPods bağımlılıklarını kurun:
   ```bash
   cd ios
   pod install
   cd ..
   ```
2. Xcode ile projeyi açmak için:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Flutter komut satırından çalıştırmak için:
   ```bash
   flutter run -d ios
   ```

---

## ⚙️ Supabase Yapılandırması

Uygulama, varsayılan olarak yerel test ve demo modunda sorunsuz açılır. İki farklı cihaz arasında anlık gerçek zamanlı senkronizasyon için:

1. [supabase.com](https://supabase.com) adresinden ücretsiz bir proje açın.
2. Projenizin **Project Settings > API** bölümünden:
   - **Project URL**
   - **Anon / Public Key**
   bilgilerini alın.
3. Uygulamayı açın, sağ üstteki **Ayarlar (Dişli)** simgesine dokunun ve bu bilgileri yapıştırıp kaydedin.

---

## 📱 Platform İzinleri

- **Android (`AndroidManifest.xml`):**
  - `INTERNET`, `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` yapılandırılmıştır.
- **iOS (`Info.plist` & `Podfile`):**
  - `NSMicrophoneUsageDescription` (Sesli sohbet için mikrofon izni).
  - `UIBackgroundModes` (`audio`, `voip`).
  - Minimum iOS Deployment Target: `13.0`.
