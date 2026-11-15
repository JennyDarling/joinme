import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/track.dart';

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  // Curated demo/popular tracks for quick starting
  static final List<Track> suggestedTracks = [
    Track(
      id: 'jfKfPfyJRdk',
      title: 'lofi hip hop radio - beats to relax/study to',
      artist: 'Lofi Girl',
      thumbnailUrl: 'https://i.ytimg.com/vi/jfKfPfyJRdk/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 45),
    ),
    Track(
      id: '5qap5aO4i9A',
      title: 'Lofi Hip Hop Chill Beats',
      artist: 'Chillhop Music',
      thumbnailUrl: 'https://i.ytimg.com/vi/5qap5aO4i9A/hqdefault.jpg',
      duration: const Duration(minutes: 4, seconds: 12),
    ),
    Track(
      id: 'DWcJFNfaw9c',
      title: 'Synthwave Radio - Chill synth / retro vibes',
      artist: 'Lofi Girl Synthwave',
      thumbnailUrl: 'https://i.ytimg.com/vi/DWcJFNfaw9c/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 30),
    ),
    Track(
      id: '21qNxnCS8WU',
      title: 'Midnight City (Ambient Piano Instrumental)',
      artist: 'Relaxing Music',
      thumbnailUrl: 'https://i.ytimg.com/vi/21qNxnCS8WU/hqdefault.jpg',
      duration: const Duration(minutes: 4, seconds: 0),
    ),
  ];

  Future<List<Track>> search(String query) async {
    if (query.trim().isEmpty) return suggestedTracks;
    try {
      final searchResults = await _yt.search.search(query);
      final tracks = <Track>[];

      for (final item in searchResults) {
        if (tracks.length >= 20) break;
        tracks.add(Track(
          id: item.id.value,
          title: item.title,
          artist: item.author,
          thumbnailUrl: item.thumbnails.mediumResUrl.isNotEmpty
              ? item.thumbnails.mediumResUrl
              : item.thumbnails.lowResUrl,
          duration: item.duration ?? const Duration(minutes: 3, seconds: 30),
        ));
      }
      return tracks;
    } catch (e) {
      // Fallback: return matches from suggested tracks
      return suggestedTracks
          .where((t) =>
              t.title.toLowerCase().contains(query.toLowerCase()) ||
              t.artist.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  /// Fetches direct audio stream URL for the given YouTube video ID
  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      if (manifest.audioOnly.isNotEmpty) {
        return manifest.audioOnly.withHighestBitrate().url.toString();
      } else if (manifest.muxed.isNotEmpty) {
        return manifest.muxed.withHighestBitrate().url.toString();
      }
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    } catch (e) {
      // If direct stream resolution fails (e.g. copyright/restricted), fallback to public direct stream
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    }
  }

  void dispose() {
    _yt.close();
  }
}
