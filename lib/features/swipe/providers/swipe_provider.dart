import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/media_item.dart';
import '../../../core/services/discovery_service.dart';
import '../../../core/services/hive_service.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import '../../watchlist/providers/watched_vault_provider.dart';

enum SwipeAction { skip, save, heart, watched }

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
  final Ref ref;
  SwipeDeckNotifier(this.ref) : super(const SwipeDeckState());

  Future<void> loadDeck({bool gemsMode = false, MediaFilter? filter}) async {
    final activeFilter = filter ?? state.filter;
    state = state.copyWith(isLoading: true, error: null, filter: activeFilter);
    try {
      final profile = HiveService.getProfile();
      final deck = await DiscoveryService.buildDeck(
        tasteSeedMovieIds: profile.tasteSeedMovieIds,
        tasteSeedTvIds: profile.tasteSeedTvIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: gemsMode,
        filter: activeFilter,
      );
      if (!mounted) return;
      state = state.copyWith(deck: deck, isLoading: false);
    } catch (e) {
      if (!mounted) return;
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
        tasteSeedMovieIds: profile.tasteSeedMovieIds,
        tasteSeedTvIds: profile.tasteSeedTvIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: gemsMode,
        filter: state.filter,
      );
      final existingIds = state.deck.map((e) => e.id).toSet();
      final filtered = newCards.where((m) => !existingIds.contains(m.id)).toList();
      if (!mounted) return;
      if (filtered.isNotEmpty) {
        state = state.copyWith(deck: [...state.deck, ...filtered]);
      }
    } catch (e) {
      // Silently fail for background pagination
    }
  }

  /// Called when a card is swiped or a button is pressed.
  Future<void> onSwiped(MediaItem item, SwipeAction action, {int? rating}) async {
    await HiveService.addToSwipeHistory(item.id);

    final profile = HiveService.getProfile();
    profile.totalSwipeCount += 1;
    await HiveService.saveProfile(profile);

    final newSwipeCount = state.swipeCount + 1;
    state = state.copyWith(swipeCount: newSwipeCount);

    if (action == SwipeAction.save) {
      await ref.read(watchlistProvider.notifier).addMedia(item);
    } else if (action == SwipeAction.watched) {
      await ref.read(watchedVaultProvider.notifier).addMedia(item, rating: rating?.toDouble());
    }
    // Heart action just feeds the swipe history (which we already did above)

    // Reload if running low
    if (state.deck.length - newSwipeCount < 5) {
      loadMore(gemsMode: profile.gemsMode);
    }
  }

  /// Called when a swipe is undone. Restores counts and removes from history/watchlist.
  Future<void> onUndo(MediaItem item, SwipeAction previousAction) async {
    if (state.swipeCount > 0) {
      state = state.copyWith(swipeCount: state.swipeCount - 1);
    }

    final profile = HiveService.getProfile();
    if (profile.totalSwipeCount > 0) {
      profile.totalSwipeCount -= 1;
      await HiveService.saveProfile(profile);
    }

    await HiveService.removeFromSwipeHistory(item.id);

    if (previousAction == SwipeAction.save) {
      await ref.read(watchlistProvider.notifier).remove(item.id);
    } else if (previousAction == SwipeAction.watched) {
      await ref.read(watchedVaultProvider.notifier).remove(item.id);
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
  (ref) => SwipeDeckNotifier(ref),
);
