import 'package:flutter_test/flutter_test.dart';
import 'package:pickd/features/swipe/providers/swipe_provider.dart';
import 'package:pickd/core/models/movie_model.dart';
import 'package:pickd/core/models/media_item.dart';

void main() {
  group('SwipeDeckState Core Logic', () {
    final mockDeck = <MediaItem>[
      MediaItem.movie(MovieModel(
        id: 1,
        title: 'Movie 1',
        overview: 'Overview 1',
        voteAverage: 0.0,
        popularity: 0.0,
        genreIds: [28, 12],
        releaseDate: '2023-01-01',
      )),
      MediaItem.movie(MovieModel(
        id: 2,
        title: 'Movie 2',
        overview: 'Overview 2',
        voteAverage: 0.0,
        popularity: 0.0,
        genreIds: [35],
        releaseDate: '2023-02-01',
      )),
    ];

    test('isDeckEmpty returns true ONLY when swipeCount >= deck length', () {
      var state = SwipeDeckState(deck: mockDeck, swipeCount: 0);
      expect(state.isDeckEmpty, false);

      state = state.copyWith(swipeCount: 1);
      expect(state.isDeckEmpty, false);

      // Reached the end
      state = state.copyWith(swipeCount: 2);
      expect(state.isDeckEmpty, true);

      // Past the end
      state = state.copyWith(swipeCount: 5);
      expect(state.isDeckEmpty, true);
    });

    test('isDeckEmpty returns false if isLoading is true', () {
      var state = SwipeDeckState(
        deck: mockDeck,
        swipeCount: 2, // Would normally be empty
        isLoading: true, // But we are currently loading more
      );
      expect(state.isDeckEmpty, false);
    });

    test('hasReachedSwipeGate triggers at 5+ swipes until gateShown is true', () {
      var state = const SwipeDeckState(swipeCount: 4);
      expect(state.hasReachedSwipeGate, false);

      state = state.copyWith(swipeCount: 5);
      expect(state.hasReachedSwipeGate, true);

      state = state.copyWith(swipeCount: 6);
      expect(state.hasReachedSwipeGate, true);

      state = state.copyWith(gateShown: true);
      expect(state.hasReachedSwipeGate, false);
    });
  });
}
