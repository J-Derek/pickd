import 'package:hive_flutter/hive_flutter.dart';

import '../models/movie_model.dart';
import '../models/tv_model.dart';
import '../models/user_profile_model.dart';

/// Manages all Hive boxes for Pickd.
class HiveService {
  static const _watchlistBoxName = 'watchlist';
  static const _tvWatchlistBoxName = 'tvWatchlist';
  static const _swipeHistoryBoxName = 'swipeHistory';
  static const _userProfileBoxName = 'userProfile';

  static Future<void> openBoxes() async {
    await Hive.openBox<MovieModel>(_watchlistBoxName);
    await Hive.openBox<TvModel>(_tvWatchlistBoxName);
    await Hive.openBox<int>(_swipeHistoryBoxName);
    await Hive.openBox<UserProfileModel>(_userProfileBoxName);
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

  // ─── Watchlist ────────────────────────────────────────────────
  static Box<MovieModel> get _watchlistBox =>
      Hive.box<MovieModel>(_watchlistBoxName);

  static List<MovieModel> getWatchlist() =>
      _watchlistBox.values.toList().reversed.toList();

  static Future<void> addToWatchlist(MovieModel movie) async {
    await _watchlistBox.put(movie.id, movie);
  }

  static Future<void> removeFromWatchlist(int movieId) async {
    await _watchlistBox.delete(movieId);
  }

  static Future<void> clearWatchlist() async {
    await _watchlistBox.clear();
  }

  static bool isInWatchlist(int movieId) =>
      _watchlistBox.containsKey(movieId) || _tvWatchlistBox.containsKey(movieId);

  // ─── TV Watchlist ─────────────────────────────────────────────
  static Box<TvModel> get _tvWatchlistBox =>
      Hive.box<TvModel>(_tvWatchlistBoxName);

  static List<TvModel> getTvWatchlist() =>
      _tvWatchlistBox.values.toList().reversed.toList();

  static Future<void> addTvToWatchlist(TvModel show) async {
    await _tvWatchlistBox.put(show.id, show);
  }

  static Future<void> removeTvFromWatchlist(int showId) async {
    await _tvWatchlistBox.delete(showId);
  }

  static Future<void> clearTvWatchlist() async {
    await _tvWatchlistBox.clear();
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
