import 'dart:async';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  bool get isPlaying => _player.playing;
  Duration get currentPosition => _player.position;
  Duration? get duration => _player.duration;

  Future<bool> loadAudioUrl(String url) async {
    try {
      await _player.stop();
      await _player.setUrl(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
    } catch (_) {}
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> seek(Duration position) async {
    if (_player.audioSource == null) return;
    try {
      final safePos = position < Duration.zero ? Duration.zero : position;
      await _player.seek(safePos);
    } catch (_) {}
  }

  /// Syncs player with remote timestamp taking network latency into account
  Future<void> syncWithRemote({
    required bool shouldPlay,
    required int positionMs,
    required int eventTimestamp,
  }) async {
    if (_player.audioSource == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final latency = (now - eventTimestamp).clamp(0, 5000); // Max 5s compensation
    final targetMs = shouldPlay ? positionMs + latency : positionMs;
    final targetDuration = Duration(milliseconds: targetMs < 0 ? 0 : targetMs);

    final currentMs = _player.position.inMilliseconds;
    final diff = (targetMs - currentMs).abs();

    // If drift is significant (> 450ms) or state differs, correct it
    if (diff > 450 || _player.playing != shouldPlay) {
      try {
        await _player.seek(targetDuration);
        if (shouldPlay && !_player.playing) {
          await _player.play();
        } else if (!shouldPlay && _player.playing) {
          await _player.pause();
        }
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
