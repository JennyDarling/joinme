import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sync_event.dart';

class WebRTCVoiceService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  bool _isMuted = false;
  bool _isInCall = false;
  bool _isConnecting = false;

  final _callStateController = StreamController<bool>.broadcast();
  final _muteStateController = StreamController<bool>.broadcast();

  Stream<bool> get callStateStream => _callStateController.stream;
  Stream<bool> get muteStateStream => _muteStateController.stream;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  bool get isMuted => _isMuted;
  bool get isInCall => _isInCall;
  bool get isConnecting => _isConnecting;

  Function(SyncEvent event)? onSendSignalingEvent;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  Future<bool> startCall({required String localUserId}) async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _isConnecting = false;
      return false;
    }

    try {
      _isConnecting = true;
      await _createPeerConnection(localUserId);

      // Create Offer
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 0,
      });
      await _peerConnection!.setLocalDescription(offer);

      onSendSignalingEvent?.call(SyncEvent(
        type: SyncEvent.typeVoiceOffer,
        senderId: localUserId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: {
          'sdp': offer.sdp,
          'type': offer.type,
        },
      ));

      _isInCall = true;
      _isConnecting = false;
      if (!_callStateController.isClosed) {
        _callStateController.add(true);
      }
      return true;
    } catch (e) {
      _isConnecting = false;
      _isInCall = false;
      if (!_callStateController.isClosed) {
        _callStateController.add(false);
      }
      return false;
    }
  }

  Future<void> handleRemoteSignaling({
    required SyncEvent event,
    required String localUserId,
  }) async {
    try {
      switch (event.type) {
        case SyncEvent.typeVoiceOffer:
          await _handleOffer(event.payload, localUserId);
          break;
        case SyncEvent.typeVoiceAnswer:
          await _handleAnswer(event.payload);
          break;
        case SyncEvent.typeVoiceIce:
          await _handleCandidate(event.payload);
          break;
        case SyncEvent.typeVoiceHangup:
          await endCall(localUserId: localUserId, broadcast: false);
          break;
      }
    } catch (_) {}
  }

  final List<RTCIceCandidate> _queuedRemoteCandidates = [];

  Future<void> _handleOffer(Map<String, dynamic> payload, String localUserId) async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    await _createPeerConnection(localUserId);
    final sdp = RTCSessionDescription(payload['sdp'] as String, payload['type'] as String);
    await _peerConnection!.setRemoteDescription(sdp);
    await _drainQueuedCandidates();

    final answer = await _peerConnection!.createAnswer({
      'offerToReceiveAudio': 1,
      'offerToReceiveVideo': 0,
    });
    await _peerConnection!.setLocalDescription(answer);

    onSendSignalingEvent?.call(SyncEvent(
      type: SyncEvent.typeVoiceAnswer,
      senderId: localUserId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      payload: {
        'sdp': answer.sdp,
        'type': answer.type,
      },
    ));

    _isInCall = true;
    if (!_callStateController.isClosed) {
      _callStateController.add(true);
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> payload) async {
    if (_peerConnection != null) {
      final sdp = RTCSessionDescription(payload['sdp'] as String, payload['type'] as String);
      await _peerConnection!.setRemoteDescription(sdp);
      await _drainQueuedCandidates();
    }
  }

  Future<void> _handleCandidate(Map<String, dynamic> payload) async {
    final candStr = payload['candidate'] as String?;
    if (candStr == null || candStr.isEmpty) return;

    final candidate = RTCIceCandidate(
      candStr,
      payload['sdpMid'] as String?,
      payload['sdpMLineIndex'] as int?,
    );
    if (_peerConnection != null) {
      final remoteDesc = await _peerConnection!.getRemoteDescription();
      if (remoteDesc != null) {
        await _peerConnection!.addCandidate(candidate);
        return;
      }
    }
    _queuedRemoteCandidates.add(candidate);
  }

  Future<void> _drainQueuedCandidates() async {
    if (_peerConnection == null) return;
    for (final candidate in _queuedRemoteCandidates) {
      try {
        await _peerConnection!.addCandidate(candidate);
      } catch (_) {}
    }
    _queuedRemoteCandidates.clear();
  }

  Future<void> _createPeerConnection(String localUserId) async {
    if (_peerConnection != null) {
      await _peerConnection?.close();
      _peerConnection = null;
    }
    if (_localStream != null) {
      _localStream?.getTracks().forEach((track) => track.stop());
      await _localStream?.dispose();
      _localStream = null;
    }

    _peerConnection = await createPeerConnection(_iceServers);

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      onSendSignalingEvent?.call(SyncEvent(
        type: SyncEvent.typeVoiceIce,
        senderId: localUserId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      ));
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        try {
          Helper.setSpeakerphoneOn(true);
        } catch (_) {}
      }
    };
  }

  void toggleMute() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        _isMuted = !_isMuted;
        audioTracks[0].enabled = !_isMuted;
        if (!_muteStateController.isClosed) {
          _muteStateController.add(_isMuted);
        }
      }
    }
  }

  Future<void> endCall({required String localUserId, bool broadcast = true}) async {
    if (broadcast) {
      onSendSignalingEvent?.call(SyncEvent(
        type: SyncEvent.typeVoiceHangup,
        senderId: localUserId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: {},
      ));
    }

    _localStream?.getTracks().forEach((track) => track.stop());
    await _localStream?.dispose();
    _localStream = null;

    _remoteStream?.getTracks().forEach((track) => track.stop());
    await _remoteStream?.dispose();
    _remoteStream = null;

    _queuedRemoteCandidates.clear();

    await _peerConnection?.close();
    _peerConnection = null;

    _isInCall = false;
    _isConnecting = false;
    _isMuted = false;
    if (!_callStateController.isClosed) {
      _callStateController.add(false);
    }
    if (!_muteStateController.isClosed) {
      _muteStateController.add(false);
    }
  }

  void dispose() {
    _queuedRemoteCandidates.clear();
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _remoteStream?.getTracks().forEach((track) => track.stop());
    _remoteStream?.dispose();
    _peerConnection?.dispose();
    _callStateController.close();
    _muteStateController.close();
  }
}
