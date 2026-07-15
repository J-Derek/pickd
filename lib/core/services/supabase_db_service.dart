import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_item.dart';

final supabaseDbServiceProvider = Provider<SupabaseDbService>((ref) {
  return SupabaseDbService();
});

class SupabaseDbService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getWatchlist(String userId) async {
    final response = await _supabase
        .from('watchlists')
        .select()
        .eq('user_id', userId)
        .eq('is_watched', false)
        .order('added_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getWatchedList(String userId) async {
    final response = await _supabase
        .from('watchlists')
        .select()
        .eq('user_id', userId)
        .eq('is_watched', true)
        .order('added_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addToWatchlist(String userId, MediaItem item) async {
    await _supabase.from('watchlists').upsert({
      'user_id': userId,
      'media_id': item.id,
      'media_type': item.isMovie ? 'movie' : 'tv',
      'title': item.title,
      'poster_path': item.posterPath,
      'is_watched': false,
      'rating': null,
    });
  }

  Future<void> removeFromWatchlist(String userId, int mediaId) async {
    await _supabase
        .from('watchlists')
        .delete()
        .eq('user_id', userId)
        .eq('media_id', mediaId);
  }

  Future<void> markAsWatched(String userId, int mediaId, int? rating) async {
    await _supabase
        .from('watchlists')
        .update({
          'is_watched': true,
          'rating': rating,
        })
        .eq('user_id', userId)
        .eq('media_id', mediaId);
  }
}
