# System Architecture & Synchronization Algorithm

## 1. High-Level Architecture

JoinMe adopts a reactive, provider-driven architectural pattern with separated service layers:

```
UI Layer (Screens & Widgets)
       ▲
       │ ChangeNotifier
       ▼
State Management (RoomProvider)
       ▲
       ├──► AudioPlayerService (just_audio)
       ├──► YouTubeService (youtube_explode_dart)
       ├──► SupabaseSyncService (supabase_flutter Realtime)
       └──► WebRTCVoiceService (flutter_webrtc)
```

- **`RoomProvider`:** Central orchestrator that handles user identity, room lifecycle, playback state, queue management, chat messages, floating reactions, and voice call state.
- **`AudioPlayerService`:** Wraps `just_audio` player instances, listens to buffering/position streams, and applies precision seek/play/pause operations.
- **`SupabaseSyncService`:** Manages connection to room channels (`joinme:room:ROOM_CODE`), broadcasts ephemeral events, and tracks presence.
- **`WebRTCVoiceService`:** Manages peer-to-peer connection for voice calling, including local media stream capture, mute controls, and signaling exchange.

---

## 2. Real-Time Synchronization Algorithm

Synchronizing audio across mobile networks requires compensating for variable network latency and clock jitter:

### Event-Driven Sync
When User A performs a playback action (Play, Pause, or Seek), a `SyncEvent` is broadcast:

```json
{
  "type": "play",
  "senderId": "uuid-user-a",
  "timestamp": 1731661200000,
  "payload": {
    "positionMs": 42000
  }
}
```

When User B receives this event:
1. Calculates elapsed network travel time:
   $$\Delta t = \text{now}() - \text{event.timestamp}$$
   *(clamped to prevent overflow during device suspension)*
2. Determines the expected target playback position:
   $$\text{targetMs} = \text{event.payload.positionMs} + \Delta t$$
3. Measures the current local player position:
   $$\text{diff} = |\text{targetMs} - \text{currentLocalMs}|$$
4. If $\text{diff} > 450\text{ ms}$ or the playback state differs (`isPlaying != shouldPlay`), the player seeks to `targetMs` and applies the target state without disrupting uninterrupted audio if drift is minimal.

### Periodic Heartbeat Drift Correction
Every 5 seconds while playing, the room Host sends a lightweight `sync_ping` event. The Guest compares local playback position against the Host's position. This ensures continuous synchronization even during network speed fluctuations.
