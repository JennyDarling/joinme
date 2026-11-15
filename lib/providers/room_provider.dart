import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/sync_event.dart';
import '../models/track.dart';
import '../services/audio_player_service.dart';
import '../services/supabase_sync_service.dart';
import '../services/webrtc_service.dart';
import '../services/youtube_service.dart';

class FloatingReaction {
  final String id;
  final String emoji;
  final double startX; // 0.0 - 1.0
  final DateTime createdAt;

  FloatingReaction({
    required this.id,
    required this.emoji,
    required this.startX,
    required this.createdAt,
  });
}

class RoomProvider extends ChangeNotifier {
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  final YouTubeService _youtubeService = YouTubeService();
  final SupabaseSyncService _syncService = SupabaseSyncService();
  final WebRTCVoiceService _webrtcService = WebRTCVoiceService();

  // User state
  String _userId = const Uuid().v4();
  String _userName = 'Music Lover';
  
  // Room state
  String? _roomCode;
  bool _isHost = false;
  bool _peerConnected = false;
  String _peerName = 'Guest';

  // Playback state
  Track? _currentTrack;
  final List<Track> _queue = [];
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  bool _isLoadingTrack = false;

  // Chat & Reactions
  final List<ChatMessage> _messages = [];
  final List<FloatingReaction> _reactions = [];

  // Voice Call
  bool _isInVoiceCall = false;
  bool _isVoiceMuted = false;
  bool _isVoiceConnecting = false;

  // Subscriptions & Timers
  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _bufferedSub;
  StreamSubscription? _syncSub;
  StreamSubscription? _chatSub;
  StreamSubscription? _peerSub;
  StreamSubscription? _callStateSub;
  StreamSubscription? _muteSub;
  Timer? _heartbeatTimer;

  // Getters
  String get userId => _userId;
  String get userName => _userName;
  String? get roomCode => _roomCode;
  bool get isHost => _isHost;
  bool get peerConnected => _peerConnected;
  String get peerName => _peerName;

  Track? get currentTrack => _currentTrack;
  List<Track> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  Duration get bufferedPosition => _bufferedPosition;
  bool get isLoadingTrack => _isLoadingTrack;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<FloatingReaction> get reactions => List.unmodifiable(_reactions);

  bool get isInVoiceCall => _isInVoiceCall;
  bool get isVoiceMuted => _isVoiceMuted;
  bool get isVoiceConnecting => _isVoiceConnecting;

  AudioPlayerService get audioPlayer => _audioPlayer;

  RoomProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? 'User-${Random().nextInt(900) + 100}';
    _userId = prefs.getString('user_id') ?? const Uuid().v4();
    await prefs.setString('user_id', _userId);

    await _syncService.initialize();

    // Listen to audio player
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _positionSub = _audioPlayer.positionStream.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        _totalDuration = dur;
        notifyListeners();
      }
    });

    _bufferedSub = _audioPlayer.bufferedPositionStream.listen((buf) {
      _bufferedPosition = buf;
      notifyListeners();
    });

    // WebRTC signaling integration
    _webrtcService.onSendSignalingEvent = (event) {
      _syncService.sendSyncEvent(event);
    };

    _callStateSub = _webrtcService.callStateStream.listen((inCall) {
      _isInVoiceCall = inCall;
      _isVoiceConnecting = _webrtcService.isConnecting;
      notifyListeners();
    });

    _muteSub = _webrtcService.muteStateStream.listen((muted) {
      _isVoiceMuted = muted;
      notifyListeners();
    });

    // Listen to sync events from remote peer
    _syncSub = _syncService.onSyncEvent.listen(_handleRemoteSyncEvent);

    // Listen to chat messages
    _chatSub = _syncService.onChatMessage.listen((msg) {
      _messages.add(msg);
      notifyListeners();
    });

    // Listen to peer presence
    _peerSub = _syncService.onPeerPresence.listen((connected) {
      _peerConnected = connected;
      if (connected) {
        _peerName = _isHost ? 'Guest Listener' : 'Room Host';
      }
      notifyListeners();
    });
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    notifyListeners();
  }

  /// Create a new room (User is Host)
  Future<String> createRoom() async {
    final code = _generateRoomCode();
    _roomCode = code;
    _isHost = true;
    _peerConnected = false;
    _messages.clear();
    _queue.clear();

    await _syncService.joinRoom(
      roomCode: code,
      userId: _userId,
      userName: _userName,
      isHost: true,
    );

    _startHeartbeat();
    notifyListeners();
    return code;
  }

  /// Join an existing room with code
  Future<bool> joinRoom(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    _roomCode = cleanCode;
    _isHost = false;
    _peerConnected = true;
    _messages.clear();
    _queue.clear();

    await _syncService.joinRoom(
      roomCode: cleanCode,
      userId: _userId,
      userName: _userName,
      isHost: false,
    );

    notifyListeners();
    return true;
  }

  /// Leave current room
  Future<void> leaveRoom() async {
    _stopHeartbeat();
    await _audioPlayer.stop();
    if (_isInVoiceCall) {
      await _webrtcService.endCall(localUserId: _userId);
    }
    await _syncService.leaveRoom();
    _roomCode = null;
    _currentTrack = null;
    _queue.clear();
    _messages.clear();
    _reactions.clear();
    notifyListeners();
  }

  /// Play track immediately
  Future<void> playTrack(Track track, {bool broadcast = true}) async {
    _isLoadingTrack = true;
    _currentTrack = track;
    notifyListeners();

    try {
      final streamUrl = await _youtubeService.getAudioStreamUrl(track.id);
      if (streamUrl != null) {
        _currentTrack = track.copyWith(audioStreamUrl: streamUrl);
        await _audioPlayer.loadAudioUrl(streamUrl);
        await _audioPlayer.play();
        _isLoadingTrack = false;
        notifyListeners();

        if (broadcast) {
          _syncService.sendSyncEvent(SyncEvent(
            type: SyncEvent.typeTrackChange,
            senderId: _userId,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            payload: track.toJson(),
          ));
        }
      }
    } catch (e) {
      _isLoadingTrack = false;
      notifyListeners();
    }
  }

  /// Toggle Play / Pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _syncService.sendSyncEvent(SyncEvent(
        type: SyncEvent.typePause,
        senderId: _userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: {'positionMs': _currentPosition.inMilliseconds},
      ));
    } else {
      await _audioPlayer.play();
      _syncService.sendSyncEvent(SyncEvent(
        type: SyncEvent.typePlay,
        senderId: _userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: {'positionMs': _currentPosition.inMilliseconds},
      ));
    }
    notifyListeners();
  }

  /// Seek to duration
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    _syncService.sendSyncEvent(SyncEvent(
      type: SyncEvent.typeSeek,
      senderId: _userId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      payload: {'positionMs': position.inMilliseconds},
    ));
    notifyListeners();
  }

  /// Add track to collaborative queue
  void addToQueue(Track track, {bool broadcast = true}) {
    final trackWithUser = track.copyWith(addedBy: _userName);
    _queue.add(trackWithUser);
    notifyListeners();

    if (broadcast) {
      _syncService.sendSyncEvent(SyncEvent(
        type: SyncEvent.typeQueueAdd,
        senderId: _userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: trackWithUser.toJson(),
      ));
    }
  }

  /// Remove track from queue
  void removeFromQueue(int index, {bool broadcast = true}) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      notifyListeners();

      if (broadcast) {
        _syncService.sendSyncEvent(SyncEvent(
          type: SyncEvent.typeQueueRemove,
          senderId: _userId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          payload: {'index': index},
        ));
      }
    }
  }

  /// Play next track in queue
  Future<void> playNext() async {
    if (_queue.isNotEmpty) {
      final nextTrack = _queue.removeAt(0);
      await playTrack(nextTrack);
    }
  }

  /// Send chat message
  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;

    final msg = ChatMessage(
      id: const Uuid().v4(),
      senderId: _userId,
      senderName: _userName,
      message: text.trim(),
      timestamp: DateTime.now(),
      isMe: true,
    );

    await _syncService.sendChatMessage(msg);
  }

  /// Send reaction burst (e.g. ❤️, 🔥, 🎵)
  void sendReaction(String emoji, {bool broadcast = true}) {
    final reaction = FloatingReaction(
      id: const Uuid().v4(),
      emoji: emoji,
      startX: Random().nextDouble() * 0.8 + 0.1, // Random horizontal position
      createdAt: DateTime.now(),
    );

    _reactions.add(reaction);
    notifyListeners();

    // Remove reaction after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      _reactions.removeWhere((r) => r.id == reaction.id);
      notifyListeners();
    });

    if (broadcast) {
      _syncService.sendSyncEvent(SyncEvent(
        type: SyncEvent.typeReaction,
        senderId: _userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: {'emoji': emoji, 'startX': reaction.startX},
      ));
    }
  }

  /// Voice call controls
  Future<void> toggleVoiceCall() async {
    if (_isInVoiceCall) {
      await _webrtcService.endCall(localUserId: _userId);
    } else {
      _isVoiceConnecting = true;
      notifyListeners();
      await _webrtcService.startCall(localUserId: _userId);
    }
  }

  void toggleVoiceMute() {
    _webrtcService.toggleMute();
  }

  /// Process incoming sync events
  void _handleRemoteSyncEvent(SyncEvent event) async {
    switch (event.type) {
      case SyncEvent.typePlay:
        final posMs = event.payload['positionMs'] as int? ?? 0;
        await _audioPlayer.syncWithRemote(
          shouldPlay: true,
          positionMs: posMs,
          eventTimestamp: event.timestamp,
        );
        break;

      case SyncEvent.typePause:
        final posMs = event.payload['positionMs'] as int? ?? 0;
        await _audioPlayer.syncWithRemote(
          shouldPlay: false,
          positionMs: posMs,
          eventTimestamp: event.timestamp,
        );
        break;

      case SyncEvent.typeSeek:
        final posMs = event.payload['positionMs'] as int? ?? 0;
        await _audioPlayer.syncWithRemote(
          shouldPlay: _isPlaying,
          positionMs: posMs,
          eventTimestamp: event.timestamp,
        );
        break;

      case SyncEvent.typeTrackChange:
        final track = Track.fromJson(event.payload);
        await playTrack(track, broadcast: false);
        break;

      case SyncEvent.typeQueueAdd:
        final track = Track.fromJson(event.payload);
        addToQueue(track, broadcast: false);
        break;

      case SyncEvent.typeQueueRemove:
        final index = event.payload['index'] as int? ?? -1;
        removeFromQueue(index, broadcast: false);
        break;

      case SyncEvent.typeReaction:
        final emoji = event.payload['emoji'] as String? ?? '❤️';
        final startX = (event.payload['startX'] as num?)?.toDouble() ?? 0.5;
        final reaction = FloatingReaction(
          id: const Uuid().v4(),
          emoji: emoji,
          startX: startX,
          createdAt: DateTime.now(),
        );
        _reactions.add(reaction);
        notifyListeners();
        Timer(const Duration(milliseconds: 2500), () {
          _reactions.removeWhere((r) => r.id == reaction.id);
          notifyListeners();
        });
        break;

      case SyncEvent.typeSyncPing:
        // Host periodic heartbeat
        if (!_isHost) {
          final posMs = event.payload['positionMs'] as int? ?? 0;
          final shouldPlay = event.payload['isPlaying'] as bool? ?? false;
          await _audioPlayer.syncWithRemote(
            shouldPlay: shouldPlay,
            positionMs: posMs,
            eventTimestamp: event.timestamp,
          );
        }
        break;

      case SyncEvent.typeVoiceOffer:
      case SyncEvent.typeVoiceAnswer:
      case SyncEvent.typeVoiceIce:
      case SyncEvent.typeVoiceHangup:
        await _webrtcService.handleRemoteSignaling(
          event: event,
          localUserId: _userId,
        );
        break;
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isHost && _currentTrack != null) {
        _syncService.sendSyncEvent(SyncEvent(
          type: SyncEvent.typeSyncPing,
          senderId: _userId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          payload: {
            'positionMs': _currentPosition.inMilliseconds,
            'isPlaying': _isPlaying,
          },
        ));
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final buffer = StringBuffer('JM-');
    for (int i = 0; i < 4; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _stopHeartbeat();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _bufferedSub?.cancel();
    _syncSub?.cancel();
    _chatSub?.cancel();
    _peerSub?.cancel();
    _callStateSub?.cancel();
    _muteSub?.cancel();
    _audioPlayer.dispose();
    _youtubeService.dispose();
    _syncService.dispose();
    _webrtcService.dispose();
    super.dispose();
  }
}
