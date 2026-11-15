import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/room_provider.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/chat_sheet.dart';
import '../widgets/emoji_burst_overlay.dart';
import '../widgets/queue_sheet.dart';
import '../widgets/voice_call_bar.dart';
import 'search_screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _copyRoomCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room code ($code) copied to clipboard!'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.surfaceLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomProvider>();
    final currentTrack = provider.currentTrack;
    final isPlaying = provider.isPlaying;
    final peerConnected = provider.peerConnected;
    final roomCode = provider.roomCode ?? 'JM-0000';

    if (isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!isPlaying && _rotationController.isAnimating) {
      _rotationController.stop();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withValues(alpha: 0.15),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        onPressed: () {
                          provider.leaveRoom();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 4),

                      // Room Code Badge
                      GestureDetector(
                        onTap: () => _copyRoomCode(roomCode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                roomCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.1,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primaryLight),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Peer Connection Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: peerConnected
                              ? AppTheme.success.withValues(alpha: 0.15)
                              : AppTheme.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: peerConnected
                                ? AppTheme.success.withValues(alpha: 0.4)
                                : AppTheme.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: peerConnected ? AppTheme.success : AppTheme.warning,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              peerConnected ? '2 Users Synced' : 'Waiting for Friend',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: peerConnected ? AppTheme.success : AppTheme.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Voice Call Bar
                const VoiceCallBar(),

                // Center Album Art / Disc
                Expanded(
                  child: Center(
                    child: currentTrack == null
                        ? GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            ),
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.music_note_rounded,
                                    size: 64,
                                    color: AppTheme.primaryLight.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tap to Choose Music',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Search on YouTube Music',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Rotating Vinyl Disc
                              RotationTransition(
                                turns: _rotationController,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(
                                            alpha: isPlaying ? 0.35 : 0.1),
                                        blurRadius: 28,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(110),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: currentTrack.thumbnailUrl,
                                          width: 220,
                                          height: 220,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              Container(color: AppTheme.surfaceLight),
                                        ),
                                        // Center spindle hole
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppTheme.background,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white30, width: 2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Song Title & Artist
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Column(
                                  children: [
                                    Text(
                                      currentTrack.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentTrack.artist,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Audio Visualizer wave
                AudioVisualizer(isPlaying: isPlaying),
                const SizedBox(height: 12),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ProgressBar(
                    progress: provider.currentPosition,
                    buffered: provider.bufferedPosition,
                    total: provider.totalDuration == Duration.zero
                        ? (currentTrack?.duration ?? Duration.zero)
                        : provider.totalDuration,
                    progressBarColor: AppTheme.primary,
                    baseBarColor: Colors.white12,
                    bufferedBarColor: Colors.white24,
                    thumbColor: Colors.white,
                    thumbGlowColor: AppTheme.primary.withValues(alpha: 0.3),
                    thumbRadius: 7,
                    timeLabelTextStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    onSeek: (duration) {
                      provider.seekTo(duration);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Media Controls (Previous, Play/Pause, Next)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Search button
                      IconButton(
                        icon: const Icon(Icons.search_rounded, size: 26),
                        color: Colors.white70,
                        tooltip: 'Search Songs',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        ),
                      ),

                      // Replay / Rewind 10s
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded, size: 28),
                        color: Colors.white,
                        tooltip: 'Rewind 10s',
                        onPressed: () {
                          final newPos = provider.currentPosition - const Duration(seconds: 10);
                          provider.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                        },
                      ),

                      // Main Play/Pause Button
                      GestureDetector(
                        onTap: () {
                          if (currentTrack == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            );
                          } else {
                            provider.togglePlayPause();
                          }
                        },
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.4),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: provider.isLoadingTrack
                              ? const Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 38,
                                  color: Colors.white,
                                ),
                        ),
                      ),

                      // Fast Forward 10s
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded, size: 28),
                        color: Colors.white,
                        tooltip: 'Forward 10s',
                        onPressed: () {
                          final newPos = provider.currentPosition + const Duration(seconds: 10);
                          provider.seekTo(newPos);
                        },
                      ),

                      // Skip Next in queue
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 30),
                        color: provider.queue.isNotEmpty ? Colors.white : Colors.white30,
                        tooltip: 'Next in Queue',
                        onPressed: provider.queue.isNotEmpty
                            ? () => provider.playNext()
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Synchronized Live Emoji Reactions Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['❤️', '🔥', '🎵', '👏', '🥳', '💃'].map((emoji) {
                      return GestureDetector(
                        onTap: () => provider.sendReaction(emoji),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // Bottom Action Buttons (Queue & Chat)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      // Collaborative Queue button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => QueueSheet.show(context),
                          icon: const Icon(Icons.queue_music_rounded, size: 18),
                          label: Text(
                            provider.queue.isEmpty
                                ? 'Shared Queue'
                                : 'Queue (${provider.queue.length})',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Chat button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => ChatSheet.show(context),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: Text(
                            provider.messages.isEmpty
                                ? 'Room Chat'
                                : 'Chat (${provider.messages.length})',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.surfaceLight,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Floating Emojis overlay
          EmojiBurstOverlay(reactions: provider.reactions),
        ],
      ),
    );
  }
}
