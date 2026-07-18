import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/models/tv_model.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/services/supabase_db_service.dart';
import '../../../core/services/hive_service.dart';

final isWatchlistLoadingProvider = StateProvider<bool>((ref) => true);

class WatchlistNotifier extends StateNotifier<List<MediaItem>> {
  final Ref ref;

  WatchlistNotifier(this.ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    Future.microtask(() {
      if (mounted) ref.read(isWatchlistLoadingProvider.notifier).state = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      
      // If no user or anonymous user, fallback to local Hive storage
      if (user == null || user.isAnonymous) {
        final history = HiveService.getSwipeHistoryList();
        final items = <MediaItem>[];
        for (final row in history) {
          if (row['action'] == 'save') {
            final isTv = row['mediaType'] == 'tv';
            if (isTv) {
              items.add(MediaItem.tv(TvModel(
                id: row['id'],
                name: row['title'] ?? 'Unknown',
                overview: '',
                posterPath: row['posterPath'],
                firstAirDate: '',
                voteAverage: 0,
                popularity: 0,
                genreIds: const [],
              )));
            } else {
              items.add(MediaItem.movie(MovieModel(
                id: row['id'],
                title: row['title'] ?? 'Unknown',
                overview: '',
                posterPath: row['posterPath'],
                releaseDate: '',
                voteAverage: 0,
                popularity: 0,
                genreIds: const [],
              )));
            }
          }
        }
        state = items;
        Future.microtask(() {
          if (mounted) ref.read(isWatchlistLoadingProvider.notifier).state = false;
        });
        return;
      }
      
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getWatchlist(user.id);
      
      final items = <MediaItem>[];
      for (final row in data) {
        if (row['is_watched'] == true) continue;
        
        final isTv = row['media_type'] == 'tv';
        if (isTv) {
          items.add(MediaItem.tv(TvModel(
            id: row['media_id'],
            name: row['title'],
            overview: '',
            posterPath: row['poster_path'],
            firstAirDate: '',
            voteAverage: 0,
            popularity: 0,
            genreIds: const [],
          )));
        } else {
          items.add(MediaItem.movie(MovieModel(
            id: row['media_id'],
            title: row['title'],
            overview: '',
            posterPath: row['poster_path'],
            releaseDate: '',
            voteAverage: 0,
            popularity: 0,
            genreIds: const [],
          )));
        }
      }
      state = items;
    } catch (e) {
      debugPrint('Supabase load error: $e');
      state = [];
    } finally {
      Future.microtask(() {
        if (mounted) ref.read(isWatchlistLoadingProvider.notifier).state = false;
      });
    }
  }

  Future<void> addMedia(MediaItem item) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.isAnonymous) {
        // We shouldn't actually add to Supabase for anon, but we probably should update the local state? 
        // Wait, for local watchlist, add is done by SwipeProvider. We don't do it here. 
        await _load();
        return;
      }
      
      await ref.read(supabaseDbServiceProvider).addToWatchlist(user.id, item);
      await _load();
    } catch (e) {
      debugPrint('Supabase add error: $e');
    }
  }

  Future<void> add(MovieModel movie) => addMedia(MediaItem.movie(movie));
  Future<void> addTv(TvModel show) => addMedia(MediaItem.tv(show));

  Future<void> remove(String mediaKey) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.isAnonymous) {
        final itemIdx = state.indexWhere((i) => i.mediaKey == mediaKey);
        if (itemIdx != -1) {
          await HiveService.removeFromSwipeHistory(state[itemIdx]);
          await _load();
        }
        return;
      }
      
      final itemIdx = state.indexWhere((i) => i.mediaKey == mediaKey);
      if (itemIdx == -1) return;
      final mediaId = state[itemIdx].id;
      final mediaType = state[itemIdx].isTv ? 'tv' : 'movie';
      
      await ref.read(supabaseDbServiceProvider).removeFromWatchlist(user.id, mediaId, mediaType);
      await _load();
    } catch (e) {
      debugPrint('Supabase remove error: $e');
    }
  }

  Future<void> clear() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.isAnonymous) {
        for (final item in state) {
          await HiveService.removeFromSwipeHistory(item);
        }
        await _load();
        return;
      }
      
      final db = ref.read(supabaseDbServiceProvider);
      for (final item in state) {
        final mediaType = item.isTv ? 'tv' : 'movie';
        await db.removeFromWatchlist(user.id, item.id, mediaType);
      }
      await _load();
    } catch (e) {
      debugPrint('Supabase clear error: $e');
    }
  }

  bool contains(String mediaKey) {
    return state.any((i) => i.mediaKey == mediaKey);
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<MediaItem>>(
  (ref) {
    ref.watch(currentUserProvider); // Rebuild when user changes
    return WatchlistNotifier(ref);
  },
);

final isInWatchlistProvider = Provider.family<bool, String>((ref, mediaKey) {
  final list = ref.watch(watchlistProvider);
  return list.any((m) => m.mediaKey == mediaKey);
});
