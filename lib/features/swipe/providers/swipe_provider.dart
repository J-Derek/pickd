import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/media_item.dart';
import '../../../core/services/discovery_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/services/supabase_db_service.dart';
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
  final bool gateShown;

  const SwipeDeckState({
    this.deck = const [],
    this.isLoading = false,
    this.error,
    this.swipeCount = 0,
    this.filter = MediaFilter.both,
    this.gateShown = false,
  });

  SwipeDeckState copyWith({
    List<MediaItem>? deck,
    bool? isLoading,
    String? error,
    int? swipeCount,
    MediaFilter? filter,
    bool? gateShown,
  }) {
    return SwipeDeckState(
      deck: deck ?? this.deck,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      swipeCount: swipeCount ?? this.swipeCount,
      filter: filter ?? this.filter,
      gateShown: gateShown ?? this.gateShown,
    );
  }

  bool get hasReachedSwipeGate => swipeCount >= 5 && !gateShown;
  bool get isDeckEmpty => swipeCount >= deck.length && !isLoading;
}

class SwipeDeckNotifier extends StateNotifier<SwipeDeckState> {
  final Ref ref;
  SwipeDeckNotifier(this.ref) : super(const SwipeDeckState(filter: MediaFilter.both));

  int _currentPage = 1;

  Future<void> loadDeck({bool gemsMode = false, MediaFilter? filter}) async {
    final activeFilter = filter ?? state.filter;
    _currentPage = 1;
    state = state.copyWith(isLoading: true, error: null, filter: activeFilter, deck: const []);
    try {
      final profile = HiveService.getProfile();
      final user = ref.read(currentUserProvider);
      
      Set<String> seenKeys = HiveService.getSwipedKeys();
      if (user != null) {
        try {
          final supabaseKeys = await ref.read(supabaseDbServiceProvider).getSwipedMediaKeys(user.id);
          seenKeys = {...seenKeys, ...supabaseKeys};
        } catch (e) {
          debugPrint('Supabase seen-keys fetch failed, using local Hive: $e');
        }
      }
      
      final deck = await DiscoveryService.buildDeck(
        tasteSeedMovieIds: profile.tasteSeedMovieIds,
        tasteSeedTvIds: profile.tasteSeedTvIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: gemsMode,
        filter: activeFilter,
        seenKeys: seenKeys,
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
      _currentPage++;
      final profile = HiveService.getProfile();
      final user = ref.read(currentUserProvider);
      
      Set<String> seenKeys = HiveService.getSwipedKeys();
      if (user != null) {
        try {
          final supabaseKeys = await ref.read(supabaseDbServiceProvider).getSwipedMediaKeys(user.id);
          seenKeys = {...seenKeys, ...supabaseKeys};
        } catch (e) {
          debugPrint('Supabase seen-keys fetch failed, using local Hive: $e');
        }
      }

      final newCards = await DiscoveryService.buildDeck(
        tasteSeedMovieIds: profile.tasteSeedMovieIds,
        tasteSeedTvIds: profile.tasteSeedTvIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: gemsMode,
        filter: state.filter,
        page: _currentPage,
        seenKeys: seenKeys,
      );
      final existingKeys = state.deck.map((e) => e.mediaKey).toSet();
      final filtered = newCards.where((m) => !existingKeys.contains(m.mediaKey)).toList();
      if (!mounted) return;
      if (filtered.isNotEmpty) {
        state = state.copyWith(deck: [...state.deck, ...filtered]);
      } else if (_currentPage < 10) {
        await loadMore(gemsMode: gemsMode);
      }
    } catch (e) {
      // Silently fail for background pagination
    }
  }

  /// Called when a card is swiped or a button is pressed.
  Future<void> onSwiped(MediaItem item, SwipeAction action, {int? rating}) async {
    // Optimistically write to Hive
    await HiveService.addToSwipeHistory(item, action.name);

    final user = ref.read(currentUserProvider);
    if (user != null) {
      try {
        await ref.read(supabaseDbServiceProvider).recordSwipe(user.id, item, action.name);
      } catch (e) {
        debugPrint('Supabase swipe error: $e');
        // Fallback: flag for sync
        await HiveService.addToSwipeHistory(item, action.name, rating: rating?.toDouble(), pendingSync: true);
      }
    }

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
    try {
      if (state.swipeCount > 0) {
        state = state.copyWith(swipeCount: state.swipeCount - 1);
      }

      final profile = HiveService.getProfile();
      if (profile.totalSwipeCount > 0) {
        profile.totalSwipeCount -= 1;
        await HiveService.saveProfile(profile);
      }

      await HiveService.removeFromSwipeHistory(item);

      final user = ref.read(currentUserProvider);
      if (user != null) {
        final mediaType = item.isTv ? 'tv' : 'movie';
        // Wrapping Supabase network calls in a separate try-catch so offline mode doesn't break undo
        try {
          await ref.read(supabaseDbServiceProvider).removeFromSwipeHistory(user.id, item.id, mediaType);
        } catch (e) {
          debugPrint('Supabase undo error: $e');
        }
      }

      if (previousAction == SwipeAction.save) {
        await ref.read(watchlistProvider.notifier).remove(item.mediaKey);
      } else if (previousAction == SwipeAction.watched) {
        await ref.read(watchedVaultProvider.notifier).remove(item.mediaKey);
      }
    } catch (e) {
      debugPrint('Undo error: $e');
    }
  }

  void resetSwipeGate() {
    state = state.copyWith(gateShown: true);
  }

  /// Switch the media filter and reload the deck.
  Future<void> setFilter(MediaFilter filter) => loadDeck(filter: filter);
}

final swipeDeckProvider =
    StateNotifierProvider<SwipeDeckNotifier, SwipeDeckState>(
  (ref) => SwipeDeckNotifier(ref),
);
