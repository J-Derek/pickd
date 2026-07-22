import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_item.dart';

import '../models/user_profile_model.dart';

/// Manages all Hive boxes for Pickd.
class HiveService {
  static const _swipeHistoryBoxName = 'swipeHistoryV2';
  static const _userProfileBoxName = 'userProfile';
  static const _recentSearchesBoxName = 'recentSearches';

  static Future<void> openBoxes() async {
    await Hive.openBox<UserProfileModel>(_userProfileBoxName);
    await Hive.openBox<String>(_swipeHistoryBoxName);
    await Hive.openBox<String>(_recentSearchesBoxName);
  }

  // ─── User Profile ─────────────────────────────────────────────
  static Box<UserProfileModel> get _profileBox =>
      Hive.box<UserProfileModel>(_userProfileBoxName);

  static UserProfileModel getProfile() {
    final existing = _profileBox.get('profile');
    if (existing != null) return existing;
    final fresh = UserProfileModel();
    _profileBox.put('profile', fresh);
    return fresh;
  }

  static Future<void> saveProfile(UserProfileModel profile) async {
    await _profileBox.put('profile', profile);
  }

  // ─── Swipe History (v2 with action) ─────────────────────────
  static Box<String> get _swipeHistoryBox => Hive.box<String>(_swipeHistoryBoxName);

  static Future<void> addToSwipeHistory(MediaItem item, String action, {double? rating, bool pendingSync = false}) async {
    final mediaType = item.isTv ? 'tv' : 'movie';
    final key = '${mediaType}_${item.id}';
    
    // Store JSON string containing action and basic info
    final Map<String, dynamic> payload = {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'mediaType': mediaType,
      'id': item.id,
      'title': item.title,
      'posterPath': item.posterPath,
      'backdropPath': item.backdropPath,
      'overview': item.overview,
      'voteAverage': item.voteAverage,
      'popularity': item.popularity,
      'genreIds': item.genreIds,
      'year': item.year,
    };
    
    if (rating != null) payload['rating'] = rating;
    if (pendingSync) payload['pendingSync'] = true;
    
    await _swipeHistoryBox.put(key, jsonEncode(payload));
  }

  static Future<void> removeFromSwipeHistory(MediaItem item) async {
    final mediaType = item.isTv ? 'tv' : 'movie';
    final key = '${mediaType}_${item.id}';
    await _swipeHistoryBox.delete(key);
  }

  static Set<String> getSwipedKeys() {
    // keys are already formatted as "movie_123" or "tv_456"
    return _swipeHistoryBox.keys.cast<String>().toSet();
  }

  static Future<void> clearSwipeHistory() async {
    await _swipeHistoryBox.clear();
  }

  static List<Map<String, dynamic>> getSwipeHistoryList() {
    final List<Map<String, dynamic>> results = [];
    for (final value in _swipeHistoryBox.values) {
      try {
        final map = jsonDecode(value) as Map<String, dynamic>;
        results.add(map);
      } catch (e) {
        // ignore malformed entries
      }
    }
    // Sort by timestamp descending
    results.sort((a, b) {
      final tA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tB.compareTo(tA);
    });
    return results;
  }
  static List<Map<String, dynamic>> getPendingSyncSwipes() {
    final List<Map<String, dynamic>> results = [];
    for (final key in _swipeHistoryBox.keys) {
      final value = _swipeHistoryBox.get(key);
      if (value != null) {
        try {
          final map = jsonDecode(value) as Map<String, dynamic>;
          if (map['pendingSync'] == true) {
            map['_key'] = key;
            results.add(map);
          }
        } catch (e) {
          // ignore
        }
      }
    }
    return results;
  }

  static Future<void> markSynced(String key) async {
    final value = _swipeHistoryBox.get(key);
    if (value != null) {
      try {
        final map = jsonDecode(value) as Map<String, dynamic>;
        map.remove('pendingSync');
        await _swipeHistoryBox.put(key, jsonEncode(map));
      } catch (e) {
        // ignore
      }
    }
  }

  // ─── Recent Searches ──────────────────────────────────────────
  static Box<String> get _recentSearchesBox => Hive.box<String>(_recentSearchesBoxName);

  static List<String> getRecentSearches() {
    return _recentSearchesBox.values.toList().reversed.toList();
  }

  static Future<void> addRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    // Remove duplicates
    final existingKey = _recentSearchesBox.keys.firstWhere(
      (k) => _recentSearchesBox.get(k)?.toLowerCase() == q.toLowerCase(),
      orElse: () => null,
    );
    if (existingKey != null) {
      await _recentSearchesBox.delete(existingKey);
    }

    // Keep history at 10 items max
    if (_recentSearchesBox.length >= 10) {
      await _recentSearchesBox.deleteAt(0);
    }

    // Add new search (keys can just be timestamps to preserve order)
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    await _recentSearchesBox.put(key, q);
  }

  static Future<void> removeRecentSearch(String query) async {
    final key = _recentSearchesBox.keys.firstWhere(
      (k) => _recentSearchesBox.get(k) == query,
      orElse: () => null,
    );
    if (key != null) {
      await _recentSearchesBox.delete(key);
    }
  }

  static Future<void> clearRecentSearches() async {
    await _recentSearchesBox.clear();
  }
}
