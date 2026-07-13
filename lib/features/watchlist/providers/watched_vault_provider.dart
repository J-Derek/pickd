import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/services/supabase_db_service.dart';
import '../../../core/services/supabase_auth_service.dart';

class WatchedVaultNotifier extends StateNotifier<List<MovieModel>> {
  final Ref ref;

  WatchedVaultNotifier(this.ref) : super([]) {
    _load();
  }

  String? get userId => ref.read(currentUserProvider)?.id;
  SupabaseDbService get _db => ref.read(supabaseDbServiceProvider);

  Future<void> _load() async {
    final uid = userId;
    if (uid == null) {
      state = [];
      return;
    }
    
    try {
      final data = await _db.getWatchedList(uid);
      state = data.map((row) {
        return MovieModel(
          id: row['media_id'] as int,
          title: (row['title'] ?? 'Unknown') as String,
          posterPath: row['poster_path'] as String?,
          overview: '',
          voteAverage: (row['rating'] != null) ? (row['rating'] as num).toDouble() : 0.0,
          popularity: 0,
          genreIds: [],
        );
      }).toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> refresh() async {
    await _load();
  }
}

final watchedVaultProvider =
    StateNotifierProvider<WatchedVaultNotifier, List<MovieModel>>(
  (ref) {
    ref.watch(currentUserProvider);
    return WatchedVaultNotifier(ref);
  },
);
