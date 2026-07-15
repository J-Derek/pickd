import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/models/tv_model.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/supabase_auth_service.dart';

class WatchlistNotifier extends StateNotifier<List<MediaItem>> {
  final Ref ref;

  WatchlistNotifier(this.ref) : super([]) {
    _load();
  }

  void _load() {
    try {
      final box = Hive.box('watchlist');
      final items = <MediaItem>[];
      for (final val in box.values) {
        if (val is MovieModel) {
          items.add(MediaItem.movie(val));
        } else if (val is TvModel) {
          items.add(MediaItem.tv(val));
        }
      }
      state = items.reversed.toList();
    } catch (e) {
      debugPrint('Hive load error: $e');
      state = [];
    }
  }

  Future<void> addMedia(MediaItem item) async {
    try {
      final box = Hive.box('watchlist');
      switch (item) {
        case MovieItem(:final movie):
          await box.put(movie.id, movie);
        case TvItem(:final show):
          await box.put(show.id, show);
      }
      _load();
    } catch (e) {
      debugPrint('Hive add error: $e');
    }
  }

  Future<void> add(MovieModel movie) => addMedia(MediaItem.movie(movie));
  Future<void> addTv(TvModel show) => addMedia(MediaItem.tv(show));

  Future<void> remove(int mediaId) async {
    try {
      final box = Hive.box('watchlist');
      await box.delete(mediaId);
      _load();
    } catch (e) {
      debugPrint('Hive remove error: $e');
    }
  }

  Future<void> clear() async {
    try {
      final box = Hive.box('watchlist');
      await box.clear();
      _load();
    } catch (e) {
      debugPrint('Hive clear error: $e');
    }
  }

  bool contains(int mediaId) {
    try {
      final box = Hive.box('watchlist');
      return box.containsKey(mediaId);
    } catch (_) {
      return false;
    }
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<MediaItem>>(
  (ref) {
    ref.watch(currentUserProvider); // Rebuild when user changes
    return WatchlistNotifier(ref);
  },
);

final isInWatchlistProvider = Provider.family<bool, int>((ref, mediaId) {
  final list = ref.watch(watchlistProvider);
  return list.any((m) => m.id == mediaId);
});
