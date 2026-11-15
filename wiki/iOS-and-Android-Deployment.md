# iOS and Android Deployment Guide

This guide covers building, testing, and running JoinMe on both **iOS** (via Xcode) and **Android** (via Android Studio or Gradle).

---

## 🍎 iOS Deployment (Xcode)

### 1. Requirements
- macOS with Xcode 15 or later
- CocoaPods (`sudo gem install cocoapods` or `brew install cocoapods`)

### 2. Installing Pods
Inside the project root:
```bash
cd ios
pod install
cd ..
```

### 3. Opening in Xcode
Always open the workspace (`.xcworkspace`), not the project file:
```bash
open ios/Runner.xcworkspace
```

### 4. Code Signing & Capabilities
1. In Xcode, select the **Runner** root project in the Project Navigator.
2. Under **Signing & Capabilities**:
   - Select your **Development Team**.
   - Provide a unique **Bundle Identifier** (e.g., `com.yourdomain.joinme`).
3. Verify that **Background Modes** is active with `Audio, AirPlay, and Picture in Picture` and `Voice over IP`.

### 5. Running on a Device / Simulator
```bash
flutter run -d ios
```

---

## 🤖 Android Deployment

### 1. Requirements
- Android SDK API 34+
- Java 17+

### 2. Permissions Verification
`android/app/src/main/AndroidManifest.xml` includes all required permissions:
- `INTERNET`
- `RECORD_AUDIO`
- `MODIFY_AUDIO_SETTINGS`
- `WAKE_LOCK`
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK`

### 3. Running on Device / Emulator
```bash
flutter run -d android
```

### 4. Generating a Release APK or App Bundle
```bash
# Build universal APK
flutter build apk --release

# Build Google Play App Bundle (.aab)
flutter build appbundle --release
```
The output file will be generated in `build/app/outputs/flutter-apk/app-release.apk`.
