import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/media_item.dart';
import '../../../core/services/discovery_service.dart';
import '../../../core/services/hive_service.dart';

/// Manages the swipe deck — loading, state, and swipe gate.
class SwipeDeckState {
  final List<MediaItem> deck;
  final bool isLoading;
  final String? error;
  final int swipeCount;
  final MediaFilter filter;

  const SwipeDeckState({
    this.deck = const [],
    this.isLoading = false,
    this.error,
    this.swipeCount = 0,
    this.filter = MediaFilter.moviesOnly,
  });

  SwipeDeckState copyWith({
    List<MediaItem>? deck,
    bool? isLoading,
    String? error,
    int? swipeCount,
    MediaFilter? filter,
  }) {
    return SwipeDeckState(
      deck: deck ?? this.deck,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      swipeCount: swipeCount ?? this.swipeCount,
      filter: filter ?? this.filter,
    );
  }

  bool get hasReachedSwipeGate => swipeCount == 5;
  bool get isDeckEmpty => swipeCount >= deck.length && !isLoading;
}

class SwipeDeckNotifier extends StateNotifier<SwipeDeckState> {
  SwipeDeckNotifier() : super(const SwipeDeckState());

  Future<void> loadDeck({bool gemsMode = false, MediaFilter? filter}) async {
    final activeFilter = filter ?? state.filter;
    state = state.copyWith(isLoading: true, error: null, filter: activeFilter);
    try {
      final profile = HiveService.getProfile();
      final deck = await DiscoveryService.buildDeck(
        tasteSeedIds: profile.tasteSeedMovieIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: gemsMode,
        filter: activeFilter,
      );
      state = state.copyWith(deck: deck, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Tap to retry.',
      );
    }
  }

  Future<void> loadMore({bool gemsMode = false}) async {
    try {
      final profile = HiveService.getProfile();
      final newCards = await DiscoveryService.buildDeck(
        tasteSeedIds: profile.tasteSeedMovieIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: gemsMode,
        filter: state.filter,
      );
      final existingIds = state.deck.map((e) => e.id).toSet();
      final filtered = newCards.where((m) => !existingIds.contains(m.id)).toList();
      if (filtered.isNotEmpty) {
        state = state.copyWith(deck: [...state.deck, ...filtered]);
      }
    } catch (e) {
      // Silently fail for background pagination
    }
  }

  /// Called when a card is swiped in either direction.
  Future<void> onSwiped(MediaItem item, bool liked) async {
    await HiveService.addToSwipeHistory(item.id);

    final profile = HiveService.getProfile();
    profile.totalSwipeCount += 1;
    await HiveService.saveProfile(profile);

    final newSwipeCount = state.swipeCount + 1;
    state = state.copyWith(swipeCount: newSwipeCount);

    // Save to the correct watchlist if liked
    if (liked) {
      switch (item) {
        case MovieItem(:final movie):
          await HiveService.addToWatchlist(movie);
        case TvItem(:final show):
          await HiveService.addTvToWatchlist(show);
      }
    }

    // Reload if running low
    if (state.deck.length - newSwipeCount < 5) {
      loadMore(gemsMode: profile.gemsMode);
    }
  }

  /// Called when a swipe is undone. Restores counts and removes from history/watchlist.
  Future<void> onUndo(MediaItem item, bool wasLiked) async {
    if (state.swipeCount > 0) {
      state = state.copyWith(swipeCount: state.swipeCount - 1);
    }

    final profile = HiveService.getProfile();
    if (profile.totalSwipeCount > 0) {
      profile.totalSwipeCount -= 1;
      await HiveService.saveProfile(profile);
    }

    await HiveService.removeFromSwipeHistory(item.id);

    if (wasLiked) {
      switch (item) {
        case MovieItem():
          await HiveService.removeFromWatchlist(item.id);
        case TvItem():
          await HiveService.removeTvFromWatchlist(item.id);
      }
    }
  }

  void resetSwipeGate() {
    state = state.copyWith(swipeCount: 0);
  }

  /// Switch the media filter and reload the deck.
  Future<void> setFilter(MediaFilter filter) => loadDeck(filter: filter);
}

final swipeDeckProvider =
    StateNotifierProvider<SwipeDeckNotifier, SwipeDeckState>(
  (ref) => SwipeDeckNotifier(),
);
