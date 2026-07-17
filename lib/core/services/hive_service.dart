import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_item.dart';

import '../models/user_profile_model.dart';

/// Manages all Hive boxes for Pickd.
class HiveService {
  static const _swipeHistoryBoxName = 'swipeHistoryV2';
  static const _userProfileBoxName = 'userProfile';
  static const _watchlistBoxName = 'watchlist';
  static const _watchedBoxName = 'watched';

  static Future<void> openBoxes() async {
    await Hive.openBox<String>(_swipeHistoryBoxName);
    await Hive.openBox<UserProfileModel>(_userProfileBoxName);
    await Hive.openBox(_watchlistBoxName);
    await Hive.openBox(_watchedBoxName);
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

  // ─── Swipe History ────────────────────────────────────────────
  static Box<String> get _historyBox => Hive.box<String>(_swipeHistoryBoxName);

  static Set<String> getSwipedKeys() => _historyBox.keys.map((k) => k.toString()).toSet();

  static List<Map<String, dynamic>> getSwipeHistoryList() {
    return _historyBox.values.map((v) => jsonDecode(v) as Map<String, dynamic>).toList().reversed.toList();
  }

  static Future<void> addToSwipeHistory(MediaItem item, String action) async {
    final key = '${item.isTv ? "tv" : "movie"}_${item.id}';
    final data = {
      'id': item.id,
      'isTv': item.isTv,
      'title': item.title,
      'posterPath': item.posterPath,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _historyBox.put(key, jsonEncode(data));
  }

  static Future<void> removeFromSwipeHistory(MediaItem item) async {
    final key = '${item.isTv ? "tv" : "movie"}_${item.id}';
    await _historyBox.delete(key);
  }

  static Future<void> clearSwipeHistory() async {
    await _historyBox.clear();
  }
}
