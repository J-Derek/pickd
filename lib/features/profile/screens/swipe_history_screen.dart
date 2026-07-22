import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/config/env.dart';
import '../../../core/models/media_item.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/models/tv_model.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../swipe/providers/swipe_provider.dart';

class SwipeHistoryScreen extends ConsumerStatefulWidget {
  const SwipeHistoryScreen({super.key});

  @override
  ConsumerState<SwipeHistoryScreen> createState() => _SwipeHistoryScreenState();
}

class _SwipeHistoryScreenState extends ConsumerState<SwipeHistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _history = HiveService.getSwipeHistoryList();
    });
  }

  void _undoSwipe(Map<String, dynamic> itemData) async {
    final id = itemData['id'] as int;
    final isTv = itemData['isTv'] as bool;
    final actionStr = itemData['action'] as String;

    SwipeAction action;
    if (actionStr == 'save') {
      action = SwipeAction.save;
    } else if (actionStr == 'watched') {
      action = SwipeAction.watched;
    } else {
      action = SwipeAction.skip;
    }

    // Create a mock media item for the undo method (it only needs the ID)
    final MediaItem mockItem;
    if (isTv) {
      mockItem = MediaItem.tv(TvModel(
        id: id,
        name: itemData['title'] ?? '',
        overview: '',
        posterPath: itemData['posterPath'],
        genreIds: [],
        firstAirDate: '',
        popularity: 0,
        voteAverage: 0,
      ));
    } else {
      mockItem = MediaItem.movie(MovieModel(
        id: id,
        title: itemData['title'] ?? '',
        overview: '',
        posterPath: itemData['posterPath'],
        genreIds: [],
        releaseDate: '',
        popularity: 0,
        voteAverage: 0,
      ));
    }

    await ref.read(swipeDeckProvider.notifier).onUndo(mockItem, action);
    _loadHistory();
    
    if (mounted) {
      showCustomSnackBar(
        context,
        message: '${itemData['title']} recovered',
        isSuccess: true,
        duration: const Duration(seconds: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Swipe History', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _history.isEmpty
          ? const Center(
              child: Text(
                'No swipe history yet.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final posterPath = item['posterPath'] as String?;
                final title = item['title'] as String? ?? 'Unknown';
                final isTv = item['isTv'] as bool? ?? false;
                final actionStr = item['action'] as String? ?? 'skip';

                IconData actionIcon;
                Color actionColor;
                String actionText;

                switch (actionStr) {
                  case 'save':
                    actionIcon = Icons.bookmark_rounded;
                    actionColor = AppTheme.accentPrimary;
                    actionText = 'Saved';
                    break;
                  case 'watched':
                    actionIcon = Icons.check_circle_rounded;
                    actionColor = Colors.green;
                    actionText = 'Watched';
                    break;
                  default:
                    actionIcon = Icons.close_rounded;
                    actionColor = Colors.red;
                    actionText = 'Skipped';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: posterPath != null
                            ? CachedNetworkImage(
                                imageUrl: '${Env.tmdbImageBaseW500}$posterPath',
                                width: 50,
                                height: 75,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.bgElevated,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isTv ? 'TV' : 'MOVIE',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(actionIcon, color: actionColor, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  actionText,
                                  style: TextStyle(
                                    color: actionColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _undoSwipe(item),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accentPrimary,
                        ),
                        child: const Text('Undo'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 75,
      color: AppTheme.bgElevated,
      child: const Icon(Icons.movie, color: AppTheme.textMuted, size: 24),
    );
  }
}
