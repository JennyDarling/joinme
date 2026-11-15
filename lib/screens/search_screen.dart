import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/track.dart';
import '../providers/room_provider.dart';
import '../services/youtube_service.dart';

class SearchScreen extends StatefulWidget {
  final bool isAddToQueueMode;

  const SearchScreen({super.key, this.isAddToQueueMode = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final YouTubeService _ytService = YouTubeService();

  List<Track> _searchResults = [];
  bool _isLoading = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchResults = YouTubeService.suggestedTracks;
  }

  int _searchCounter = 0;

  void _onSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery == _currentQuery) return;
    _currentQuery = cleanQuery;
    final requestId = ++_searchCounter;

    setState(() => _isLoading = true);
    final results = await _ytService.search(cleanQuery);
    if (mounted && requestId == _searchCounter) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ytService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAddToQueueMode ? 'Add Song to Queue' : 'Search YouTube Music'),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search songs, artists, or albums...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // Categories / Suggested Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Text(
                  _currentQuery.isEmpty ? 'RECOMMENDED TRACKS' : 'SEARCH RESULTS',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          // Search Results List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.music_off_rounded,
                                size: 54, color: Colors.white.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text(
                              'No results found.\nTry a different search term.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final track = _searchResults[index];
                          final isCurrentPlaying = provider.currentTrack?.id == track.id;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isCurrentPlaying
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : AppTheme.surfaceLight.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isCurrentPlaying
                                    ? AppTheme.primary.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.04),
                              ),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: track.thumbnailUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) =>
                                      const Icon(Icons.music_note, color: Colors.white54),
                                ),
                              ),
                              title: Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrentPlaying ? AppTheme.primaryLight : Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${track.artist} • ${track.formattedDuration}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Add to queue button
                                  IconButton(
                                    icon: const Icon(Icons.playlist_add_rounded),
                                    color: AppTheme.secondary,
                                    tooltip: 'Add to Queue',
                                    onPressed: () {
                                      provider.addToQueue(track);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('"${track.title}" added to queue'),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: AppTheme.surfaceLight,
                                        ),
                                      );
                                      if (widget.isAddToQueueMode) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                  // Play Now Button
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_fill_rounded),
                                    color: AppTheme.primary,
                                    iconSize: 32,
                                    tooltip: 'Play Now',
                                    onPressed: () {
                                      provider.playTrack(track);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
