import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_profile_model.dart';

/// Manages all Hive boxes for Pickd.
class HiveService {
  static const _swipeHistoryBoxName = 'swipeHistory';
  static const _userProfileBoxName = 'userProfile';
  static const _watchlistBoxName = 'watchlist';
  static const _watchedBoxName = 'watched';

  static Future<void> openBoxes() async {
    await Hive.openBox<int>(_swipeHistoryBoxName);
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
  static Box<int> get _historyBox => Hive.box<int>(_swipeHistoryBoxName);

  static Set<int> getSwipeHistory() => _historyBox.values.toSet();

  static Future<void> addToSwipeHistory(int movieId) async {
    await _historyBox.put(movieId, movieId);
  }

  static bool hasBeenSwiped(int movieId) =>
      _historyBox.containsKey(movieId);

  static Future<void> removeFromSwipeHistory(int movieId) async {
    await _historyBox.delete(movieId);
  }

  static Future<void> clearSwipeHistory() async {
    await _historyBox.clear();
  }
}
