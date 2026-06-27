import 'package:flutter_test/flutter_test.dart';
import 'package:pickd/core/models/movie_model.dart';
import 'package:pickd/core/models/user_profile_model.dart';

void main() {
  group('MovieModel Tests', () {
    test('fromJson safely handles missing fields and defaults', () {
      final json = {
        'id': 999,
        'title': 'Test Movie',
        // missing overview, poster_path, etc.
      };

      final movie = MovieModel.fromJson(json);
      
      expect(movie.id, 999);
      expect(movie.title, 'Test Movie');
      expect(movie.overview, '');
      expect(movie.posterPath, null);
      expect(movie.backdropPath, null);
      expect(movie.genreIds, isEmpty);
      expect(movie.releaseDate, null);
      expect(movie.popularity, 0.0);
    });

    test('releaseYear getter works correctly', () {
      final m1 = MovieModel(id: 1, title: 'A', overview: '', voteAverage: 0.0, popularity: 0.0, genreIds: [], releaseDate: '1999-10-15');
      expect(m1.releaseYear, 1999);

      final m2 = MovieModel(id: 2, title: 'B', overview: '', voteAverage: 0.0, popularity: 0.0, genreIds: [], releaseDate: '');
      expect(m2.releaseYear, 0);

      final m3 = MovieModel(id: 3, title: 'C', overview: '', voteAverage: 0.0, popularity: 0.0, genreIds: [], releaseDate: 'not-a-date');
      expect(m3.releaseYear, 0);
    });
  });

  group('UserProfileModel Tests', () {
    test('hasReachedSwipeGate works correctly', () {
      final profile = UserProfileModel();
      
      expect(profile.hasReachedSwipeGate, false);
      
      profile.totalSwipeCount = 4;
      expect(profile.hasReachedSwipeGate, false);

      profile.totalSwipeCount = 5;
      expect(profile.hasReachedSwipeGate, true);

      profile.swipeGateDismissed = true;
      expect(profile.hasReachedSwipeGate, false);
    });
  });
}
