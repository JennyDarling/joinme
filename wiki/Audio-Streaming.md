# Audio Streaming Pipeline

## 1. YouTube Audio Extraction

JoinMe extracts direct audio-only streams on demand using `youtube_explode_dart`.

### Why `youtube_explode_dart`?
- **No API Keys or Quotas:** Bypasses Google Cloud YouTube Data API v3 quota restrictions, which are strictly capped on free tiers.
- **Audio-Only Bandwidth Efficiency:** Extracts audio streams (`audio/mp4` or `audio/webm`) without downloading bulky video track data, reducing mobile data consumption by over 80%.
- **High Bitrate Selection:** Always queries the stream manifest for the highest available bitrate stream (`manifest.audioOnly.withHighestBitrate()`).

```dart
final manifest = await yt.videos.streamsClient.getManifest(videoId);
final audioStream = manifest.audioOnly.withHighestBitrate();
final streamUrl = audioStream.url.toString();
```

---

## 2. Playback with `just_audio`

`just_audio` provides hardware-accelerated, native audio decoders on both iOS (AVPlayer) and Android (ExoPlayer).

### Key Features Utilized:
- **Streaming Buffering:** Handles progressive HTTP/HTTPS audio streams without requiring the entire file to be downloaded before playback starts.
- **Position & Duration Streams:** Emits millisecond-accurate position updates (`positionStream`) used by the custom `AudioVisualizer` and `ProgressBar`.
- **Background Playback:** Configured to continue playing when the app is minimized or the screen is locked.
