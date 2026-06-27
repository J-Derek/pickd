import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/models/tv_model.dart';
import '../../../core/services/hive_service.dart';

class WatchlistNotifier extends StateNotifier<List<MovieModel>> {
  WatchlistNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.getWatchlist();
  }

  Future<void> add(MovieModel movie) async {
    await HiveService.addToWatchlist(movie);
    state = HiveService.getWatchlist();
  }

  Future<void> addTv(TvModel show) async {
    await HiveService.addTvToWatchlist(show);
    state = HiveService.getWatchlist();
  }

  Future<void> remove(int movieId) async {
    await HiveService.removeFromWatchlist(movieId);
    state = HiveService.getWatchlist();
  }

  Future<void> clear() async {
    await HiveService.clearWatchlist();
    state = HiveService.getWatchlist();
  }

  bool contains(int movieId) => state.any((m) => m.id == movieId);
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<MovieModel>>(
  (ref) => WatchlistNotifier(),
);

final isInWatchlistProvider = Provider.family<bool, int>((ref, movieId) {
  final list = ref.watch(watchlistProvider);
  return list.any((m) => m.id == movieId);
});
