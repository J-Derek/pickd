import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/models/tv_model.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/supabase_auth_service.dart';

class WatchedVaultNotifier extends StateNotifier<List<MediaItem>> {
  final Ref ref;

  WatchedVaultNotifier(this.ref) : super([]) {
    _load();
  }

  void _load() {
    try {
      final box = Hive.box('watched');
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
      debugPrint('Hive watched load error: $e');
      state = [];
    }
  }

  Future<void> addMedia(MediaItem item, {double? rating}) async {
    try {
      final box = Hive.box('watched');
      switch (item) {
        case MovieItem(:final movie):
          final updatedMovie = movie.copyWith(
            voteAverage: rating ?? movie.voteAverage,
          );
          await box.put(updatedMovie.id, updatedMovie);
        case TvItem(:final show):
          final updatedShow = show.copyWith(
            voteAverage: rating ?? show.voteAverage,
          );
          await box.put(updatedShow.id, updatedShow);
      }
      _load();
    } catch (e) {
      debugPrint('Hive watched add error: $e');
    }
  }

  Future<void> add(MovieModel movie, {double? rating}) =>
      addMedia(MediaItem.movie(movie), rating: rating);

  Future<void> addTv(TvModel show, {double? rating}) =>
      addMedia(MediaItem.tv(show), rating: rating);

  Future<void> remove(int mediaId) async {
    try {
      final box = Hive.box('watched');
      await box.delete(mediaId);
      _load();
    } catch (e) {
      debugPrint('Hive watched remove error: $e');
    }
  }

  Future<void> clear() async {
    try {
      final box = Hive.box('watched');
      await box.clear();
      _load();
    } catch (e) {
      debugPrint('Hive watched clear error: $e');
    }
  }

  Future<void> refresh() async {
    _load();
  }
}

final watchedVaultProvider =
    StateNotifierProvider<WatchedVaultNotifier, List<MediaItem>>(
  (ref) {
    ref.watch(currentUserProvider); // Rebuild when user changes
    return WatchedVaultNotifier(ref);
  },
);
