import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/discovery_service.dart';

/// Manages the swipe deck — loading, state, and swipe gate.
class SwipeDeckState {
  final List<MovieModel> deck;
  final bool isLoading;
  final String? error;
  final int swipeCount;

  const SwipeDeckState({
    this.deck = const [],
    this.isLoading = false,
    this.error,
    this.swipeCount = 0,
  });

  SwipeDeckState copyWith({
    List<MovieModel>? deck,
    bool? isLoading,
    String? error,
    int? swipeCount,
  }) {
    return SwipeDeckState(
      deck: deck ?? this.deck,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      swipeCount: swipeCount ?? this.swipeCount,
    );
  }

  bool get hasReachedSwipeGate => swipeCount == 5;
  bool get isDeckEmpty => swipeCount >= deck.length && !isLoading;
}

class SwipeDeckNotifier extends StateNotifier<SwipeDeckState> {
  SwipeDeckNotifier() : super(const SwipeDeckState());

  Future<void> loadDeck({bool gemsMode = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = HiveService.getProfile();
      final deck = await DiscoveryService.buildDeck(
        tasteSeedIds: profile.tasteSeedMovieIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: gemsMode,
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
  Future<void> onSwiped(MovieModel movie, bool liked) async {
    await HiveService.addToSwipeHistory(movie.id);

    final profile = HiveService.getProfile();
    profile.totalSwipeCount += 1;
    await HiveService.saveProfile(profile);

    final newSwipeCount = state.swipeCount + 1;
    state = state.copyWith(swipeCount: newSwipeCount);

    // Reload if running low
    if (state.deck.length - newSwipeCount < 5) {
      loadMore(gemsMode: profile.gemsMode);
    }
  }

  /// Called when a swipe is undone. Restores counts and removes from history/watchlist.
  Future<void> onUndo(MovieModel movie, bool wasLiked) async {
    if (state.swipeCount > 0) {
      state = state.copyWith(swipeCount: state.swipeCount - 1);
    }

    final profile = HiveService.getProfile();
    if (profile.totalSwipeCount > 0) {
      profile.totalSwipeCount -= 1;
      await HiveService.saveProfile(profile);
    }

    await HiveService.removeFromSwipeHistory(movie.id);

    if (wasLiked) {
      await HiveService.removeFromWatchlist(movie.id);
    }
  }

  void resetSwipeGate() {
    state = state.copyWith(swipeCount: 0);
  }
}

final swipeDeckProvider =
    StateNotifierProvider<SwipeDeckNotifier, SwipeDeckState>(
  (ref) => SwipeDeckNotifier(),
);
