import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/services/supabase_db_service.dart';

final migrationServiceProvider = Provider<MigrationService>((ref) {
  return MigrationService(ref);
});

class MigrationService {
  final Ref ref;

  MigrationService(this.ref);

  Future<void> migrateGuestDataToSupabase() async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) return;

    final db = ref.read(supabaseDbServiceProvider);
    final profile = HiveService.getProfile();

    try {
      debugPrint('Starting Guest -> Supabase Migration...');

      // 1. Sync Taste Seeds
      if (profile.tasteSeedMovieIds.isNotEmpty || profile.tasteSeedTvIds.isNotEmpty) {
        await db.syncTasteSeeds(
          user.id,
          profile.tasteSeedMovieIds,
          profile.tasteSeedTvIds,
        );
      }
      // Also update allowOldMovies
      await db.updateAllowOldMovies(user.id, profile.allowOldMovies);

      // 2. Batch Sync Swipe History & Watchlists
      final swipeHistory = HiveService.getSwipeHistoryList();
      final List<Map<String, dynamic>> swipeRows = [];
      final List<Map<String, dynamic>> watchlistRows = [];

      for (final row in swipeHistory) {
        final mediaId = row['id'];
        final originalAction = row['action'];
        var action = originalAction;
        final mediaType = row['mediaType'];
        final rating = row['rating'];
        
        // Map 'heart' to 'save' to satisfy DB CHECK constraint
        if (action == 'heart') {
          action = 'save';
        }

        swipeRows.add({
          'user_id': user.id,
          'media_id': mediaId,
          'media_type': mediaType,
          'title': row['title'] ?? 'Unknown',
          'poster_path': row['posterPath'],
          'action': action,
        });
        
        // Build watchlist rows concurrently based on the original action
        if (originalAction == 'save' || originalAction == 'watched') {
          watchlistRows.add({
            'user_id': user.id,
            'media_id': mediaId,
            'media_type': mediaType,
            'title': row['title'] ?? 'Unknown',
            'poster_path': row['posterPath'],
            'is_watched': originalAction == 'watched',
            if (rating != null) 'rating': rating,
          });
        }
      }

      await db.batchUpsertSwipeHistory(swipeRows);
      await db.batchUpsertWatchlists(watchlistRows);

      debugPrint('Migration Complete!');
      
    } catch (e) {
      debugPrint('Migration Error: $e');
    }
  }

  Future<void> flushPendingSync() async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) return;

    final db = ref.read(supabaseDbServiceProvider);
    final pending = HiveService.getPendingSyncSwipes();
    if (pending.isEmpty) return;

    debugPrint('Flushing ${pending.length} pending swipes to Supabase...');

    final List<Map<String, dynamic>> swipeRows = [];
    final List<Map<String, dynamic>> watchlistRows = [];

    for (final row in pending) {
      final mediaId = row['id'];
      final originalAction = row['action'];
      var action = originalAction;
      final mediaType = row['mediaType'];
      final rating = row['rating'];
      
      if (action == 'heart') {
        action = 'save';
      }

      swipeRows.add({
        'user_id': user.id,
        'media_id': mediaId,
        'media_type': mediaType,
        'title': row['title'] ?? 'Unknown',
        'poster_path': row['posterPath'],
        'action': action,
      });
      
      if (originalAction == 'save' || originalAction == 'watched') {
        watchlistRows.add({
          'user_id': user.id,
          'media_id': mediaId,
          'media_type': mediaType,
          'title': row['title'] ?? 'Unknown',
          'poster_path': row['posterPath'],
          'is_watched': originalAction == 'watched',
          if (rating != null) 'rating': rating,
        });
      }
    }

    try {
      await db.batchUpsertSwipeHistory(swipeRows);
      await db.batchUpsertWatchlists(watchlistRows);

      for (final row in pending) {
        final key = row['_key'];
        if (key != null) {
          await HiveService.markSynced(key);
        }
      }
      debugPrint('Flush Complete!');
    } catch (e) {
      debugPrint('Flush Error: $e');
    }
  }
}
