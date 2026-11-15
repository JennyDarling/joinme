import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/room_provider.dart';

class VoiceCallBar extends StatelessWidget {
  const VoiceCallBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomProvider>();
    final isInCall = provider.isInVoiceCall;
    final isConnecting = provider.isVoiceConnecting;
    final isMuted = provider.isVoiceMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isInCall
            ? AppTheme.surfaceLight
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInCall
              ? AppTheme.success.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isInCall
                  ? AppTheme.success.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isInCall
                  ? (isMuted ? Icons.mic_off_rounded : Icons.mic_rounded)
                  : Icons.headset_mic_rounded,
              size: 16,
              color: isInCall ? AppTheme.success : Colors.white70,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isInCall
                      ? 'Voice Chat Active'
                      : (isConnecting ? 'Connecting...' : 'Voice Chat'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isInCall ? AppTheme.success : Colors.white,
                  ),
                ),
                Text(
                  isInCall
                      ? (isMuted ? 'Microphone muted' : 'Live audio connected')
                      : 'Talk while listening together',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          if (isInCall) ...[
            // Mute / Unmute Button
            IconButton(
              icon: Icon(
                isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                size: 20,
                color: isMuted ? AppTheme.accent : Colors.white,
              ),
              onPressed: () => provider.toggleVoiceMute(),
              tooltip: isMuted ? 'Unmute Mic' : 'Mute Mic',
            ),
            // End Call Button
            IconButton(
              icon: const Icon(
                Icons.call_end_rounded,
                size: 20,
                color: AppTheme.accent,
              ),
              onPressed: () => provider.toggleVoiceCall(),
              tooltip: 'End Call',
            ),
          ] else ...[
            // Start Call Button
            ElevatedButton.icon(
              onPressed: isConnecting ? null : () => provider.toggleVoiceCall(),
              icon: isConnecting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.call_rounded, size: 14),
              label: Text(isConnecting ? '...' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
