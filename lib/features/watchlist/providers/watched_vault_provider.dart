import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/models/tv_model.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/services/supabase_db_service.dart';
import '../../../core/services/hive_service.dart';

final isWatchedLoadingProvider = StateProvider<bool>((ref) => true);

class WatchedVaultNotifier extends StateNotifier<List<MediaItem>> {
  final Ref ref;

  WatchedVaultNotifier(this.ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    Future.microtask(() {
      if (mounted) ref.read(isWatchedLoadingProvider.notifier).state = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      
      // If no user or anonymous user, fallback to local Hive storage
      if (user == null || user.isAnonymous) {
        final history = HiveService.getSwipeHistoryList();
        final items = <MediaItem>[];
        for (final row in history) {
          if (row['action'] == 'watched') {
            final isTv = row['mediaType'] == 'tv';
            if (isTv) {
              items.add(MediaItem.tv(TvModel(
                id: row['id'],
                name: row['title'] ?? 'Unknown',
                overview: row['overview'] ?? '',
                posterPath: row['posterPath'],
                backdropPath: row['backdropPath'],
                firstAirDate: row['year']?.toString() ?? '',
                voteAverage: (row['voteAverage'] as num?)?.toDouble() ?? 0,
                popularity: (row['popularity'] as num?)?.toDouble() ?? 0,
                genreIds: (row['genreIds'] as List?)?.cast<int>() ?? const [],
              )));
            } else {
              items.add(MediaItem.movie(MovieModel(
                id: row['id'],
                title: row['title'] ?? 'Unknown',
                overview: row['overview'] ?? '',
                posterPath: row['posterPath'],
                backdropPath: row['backdropPath'],
                releaseDate: row['year']?.toString() ?? '',
                voteAverage: (row['voteAverage'] as num?)?.toDouble() ?? 0,
                popularity: (row['popularity'] as num?)?.toDouble() ?? 0,
                genreIds: (row['genreIds'] as List?)?.cast<int>() ?? const [],
              )));
            }
          }
        }
        state = items;
        Future.microtask(() {
          if (mounted) ref.read(isWatchedLoadingProvider.notifier).state = false;
        });
        return;
      }
      
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getWatchlist(user.id);
      
      final items = <MediaItem>[];
      for (final row in data) {
        if (row['is_watched'] != true) continue;
        
        final isTv = row['media_type'] == 'tv';
        final rating = (row['rating'] as num?)?.toDouble() ?? 0.0;
        
        if (isTv) {
          items.add(MediaItem.tv(TvModel(
            id: row['media_id'],
            name: row['title'],
            overview: '',
            posterPath: row['poster_path'],
            firstAirDate: '',
            voteAverage: rating,
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
            voteAverage: rating,
            popularity: 0,
            genreIds: const [],
          )));
        }
      }
      state = items;
    } catch (e) {
      debugPrint('Supabase watched load error: $e');
      state = [];
    } finally {
      Future.microtask(() {
        if (mounted) ref.read(isWatchedLoadingProvider.notifier).state = false;
      });
    }
  }

  Future<void> addMedia(MediaItem item, {double? rating}) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.isAnonymous) {
        await HiveService.addToSwipeHistory(item, 'watched', rating: rating);
        await _load();
        return;
      }
      
      final db = ref.read(supabaseDbServiceProvider);
      final mediaType = item.isTv ? 'tv' : 'movie';
      
      // If adding straight to watched, upsert with is_watched=true
      await db.addToWatchlist(user.id, item, isWatched: true);
      
      // If rating provided, update it
      if (rating != null) {
        await db.markAsWatched(user.id, item.id, mediaType, rating.toInt());
      } else {
        await db.markAsWatched(user.id, item.id, mediaType, null);
      }
      
      await _load();
    } catch (e) {
      debugPrint('Supabase watched add error: $e');
    }
  }

  Future<void> add(MovieModel movie, {double? rating}) =>
      addMedia(MediaItem.movie(movie), rating: rating);

  Future<void> addTv(TvModel show, {double? rating}) =>
      addMedia(MediaItem.tv(show), rating: rating);

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
      debugPrint('Supabase watched remove error: $e');
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
      debugPrint('Supabase watched clear error: $e');
    }
  }

  Future<void> refresh() async {
    await _load();
  }
}

final watchedVaultProvider =
    StateNotifierProvider<WatchedVaultNotifier, List<MediaItem>>(
  (ref) {
    ref.watch(currentUserProvider); // Rebuild when user changes
    return WatchedVaultNotifier(ref);
  },
);
