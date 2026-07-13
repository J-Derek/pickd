import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/models/tv_model.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/supabase_db_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WatchlistNotifier extends StateNotifier<List<MovieModel>> {
  final Ref ref;

  WatchlistNotifier(this.ref) : super([]) {
    _load();
  }

  String? get userId => Supabase.instance.client.auth.currentUser?.id;
  SupabaseDbService get _db => ref.read(supabaseDbServiceProvider);

  Future<void> _load() async {
    final uid = userId;
    if (uid == null) {
      state = [];
      return;
    }
    
    try {
      final data = await _db.getWatchlist(uid);
      state = data.map((row) {
        return MovieModel(
          id: row['media_id'] as int,
          title: (row['title'] ?? 'Unknown') as String,
          posterPath: row['poster_path'] as String?,
          overview: '',
          voteAverage: 0,
          popularity: 0,
          genreIds: [],
        );
      }).toList();
    } catch (e) {
      // Handle error gracefully if DB fails
      state = [];
    }
  }

  Future<void> add(MovieModel movie) async {
    final uid = userId;
    if (uid == null) return;
    
    await _db.addToWatchlist(uid, MediaItem.movie(movie));
    await _load();
  }

  Future<void> addTv(TvModel show) async {
    final uid = userId;
    if (uid == null) return;

    await _db.addToWatchlist(uid, MediaItem.tv(show));
    await _load();
  }

  Future<void> remove(int movieId) async {
    final uid = userId;
    if (uid == null) return;

    await _db.removeFromWatchlist(uid, movieId);
    await _load();
  }

  Future<void> clear() async {
    final uid = userId;
    if (uid == null) return;
    
    // For simplicity, remove them one by one based on current state
    for (var item in state) {
      await _db.removeFromWatchlist(uid, item.id);
    }
    await _load();
  }

  bool contains(int movieId) => state.any((m) => m.id == movieId);
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<MovieModel>>(
  (ref) {
    ref.watch(currentUserProvider); // Rebuild when user changes
    return WatchlistNotifier(ref);
  },
);

final isInWatchlistProvider = Provider.family<bool, int>((ref, movieId) {
  final list = ref.watch(watchlistProvider);
  return list.any((m) => m.id == movieId);
});
