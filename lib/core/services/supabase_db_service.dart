import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_item.dart';

final supabaseDbServiceProvider = Provider<SupabaseDbService>((ref) {
  return SupabaseDbService();
});

class SupabaseDbService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // PROFILES (TASTE SEEDS & PREFS)
  // ---------------------------------------------------------------------------

  Future<void> syncTasteSeeds(String userId, List<int> movieIds, List<int> tvIds) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'taste_seed_movie_ids': movieIds,
      'taste_seed_tv_ids': tvIds,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'id');
  }

  Future<void> updateAllowOldMovies(String userId, bool allow) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'allow_old_movies': allow,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'id');
  }

  Future<Map<String, dynamic>?> getProfileDetails(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('display_name, avatar_url')
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> updateProfileDetails(String userId, String? displayName, String? avatarUrl) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'id');
  }

  // ---------------------------------------------------------------------------
  // SWIPE HISTORY
  // ---------------------------------------------------------------------------

  Future<void> recordSwipe(String userId, MediaItem item, String action) async {
    // Map 'heart' to 'save' for backend storage
    final mappedAction = action == 'heart' ? 'save' : action;
    final mediaType = item.isTv ? 'tv' : 'movie';
    
    // 1. Record the swipe
    await _supabase.from('swipe_history').upsert({
      'user_id': userId,
      'media_id': item.id,
      'media_type': mediaType,
      'title': item.title,
      'poster_path': item.posterPath,
      'action': mappedAction,
    }, onConflict: 'user_id,media_id,media_type');

    // 2. If the ORIGINAL action was "save" or "watched", also ensure it's in their watchlist
    if (mappedAction == 'save' || mappedAction == 'watched') {
      await addToWatchlist(userId, item, isWatched: mappedAction == 'watched');
    }
  }

  Future<Set<String>> getSwipedMediaKeys(String userId) async {
    final response = await _supabase
        .from('swipe_history')
        .select('media_id, media_type')
        .eq('user_id', userId);
    
    final Set<String> keys = {};
    for (final row in List<Map<String, dynamic>>.from(response)) {
      keys.add('${row['media_type']}_${row['media_id']}');
    }
    return keys;
  }

  Future<int> getSwipeCount(String userId) async {
    final keys = await getSwipedMediaKeys(userId);
    return keys.length;
  }

  Future<void> removeFromSwipeHistory(String userId, int mediaId, String mediaType) async {
    await _supabase
        .from('swipe_history')
        .delete()
        .eq('user_id', userId)
        .eq('media_id', mediaId)
        .eq('media_type', mediaType);
  }

  // ---------------------------------------------------------------------------
  // WATCHLIST
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getWatchlist(String userId) async {
    final response = await _supabase
        .from('watchlists')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addToWatchlist(String userId, MediaItem item, {bool isWatched = false, int? rating}) async {
    final mediaType = item.isTv ? 'tv' : 'movie';
    
    final payload = <String, dynamic>{
      'user_id': userId,
      'media_id': item.id,
      'media_type': mediaType,
      'title': item.title,
      'poster_path': item.posterPath,
    };
    
    if (isWatched) {
      payload['is_watched'] = true;
      if (rating != null) {
        payload['rating'] = rating;
      }
    }

    await _supabase.from('watchlists').upsert(payload, onConflict: 'user_id,media_id,media_type');
  }

  Future<void> removeFromWatchlist(String userId, int mediaId, String mediaType) async {
    await _supabase
        .from('watchlists')
        .delete()
        .eq('user_id', userId)
        .eq('media_id', mediaId)
        .eq('media_type', mediaType);
  }

  Future<void> markAsWatched(String userId, int mediaId, String mediaType, int? rating) async {
    final payload = <String, dynamic>{
      'is_watched': true,
    };
    if (rating != null) {
      payload['rating'] = rating;
    }

    await _supabase
        .from('watchlists')
        .update(payload)
        .eq('user_id', userId)
        .eq('media_id', mediaId)
        .eq('media_type', mediaType);
  }

  // ---------------------------------------------------------------------------
  // BATCH OPERATIONS FOR MIGRATION
  // ---------------------------------------------------------------------------

  Future<void> batchUpsertSwipeHistory(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _supabase.from('swipe_history').upsert(rows, onConflict: 'user_id,media_id,media_type');
  }

  Future<void> batchUpsertWatchlists(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _supabase.from('watchlists').upsert(rows, onConflict: 'user_id,media_id,media_type');
  }
}
