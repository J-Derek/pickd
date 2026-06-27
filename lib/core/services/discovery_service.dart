import '../config/env.dart';
import '../config/mood_config.dart';
import '../models/movie_model.dart';
import '../services/hive_service.dart';
import '../services/tmdb_service.dart';

/// The recommendation engine. Builds a curated swipe deck from taste seeds,
/// mood, and hidden gem filters. This is the core business logic of Pickd.
class DiscoveryService {
  static const _deckSize = 30;

  /// Builds a full swipe deck from the user's taste + mood preferences.
  static Future<List<MovieModel>> buildDeck({
    required List<int> tasteSeedIds,
    required List<String> moodIds,
    bool gemsMode = false,
  }) async {
    final seenIds = HiveService.getSwipeHistory();
    final collected = <int, MovieModel>{};

    // Get required genre IDs from selected moods
    final selectedMoods = kMoods.where((m) => moodIds.contains(m.id));
    final moodGenreIds = selectedMoods.expand((m) => m.genreIds).toSet();

    bool isRecent(MovieModel movie) {
      if (gemsMode) return true; // Gems mode specifically allows old movies
      if (movie.releaseDate?.isEmpty ?? true) return false;
      return movie.releaseYear >= 1995;
    }

    // 1. Pull recommendations from taste seeds (primary signal)
    if (tasteSeedIds.isNotEmpty) {
      final seedsToUse = tasteSeedIds.take(3).toList();
      final futures = seedsToUse.map(TmdbService.getRecommendations);
      final results = await Future.wait(futures);
      for (final list in results) {
        for (final movie in list) {
          if (!isRecent(movie)) continue;
          // INTERSECTION LOGIC: Only keep seed recs that match the selected mood!
          if (moodGenreIds.isEmpty || movie.genreIds.any((id) => moodGenreIds.contains(id))) {
            collected[movie.id] = movie;
          }
        }
      }

      // Also pull "similar" for each seed
      final similarFutures = seedsToUse.map(TmdbService.getSimilar);
      final similarResults = await Future.wait(similarFutures);
      for (final list in similarResults) {
        for (final movie in list) {
          if (!isRecent(movie)) continue;
          if (moodGenreIds.isEmpty || movie.genreIds.any((id) => moodGenreIds.contains(id))) {
            collected[movie.id] = movie;
          }
        }
      }
    }

    // 2. Pull mood-based discoveries
    if (moodIds.isNotEmpty) {
      final selectedMoods = kMoods.where((m) => moodIds.contains(m.id));
      final genreIds = selectedMoods.expand((m) => m.genreIds).toList();

      if (genreIds.isNotEmpty) {
        final moodMovies = await TmdbService.discoverMovies(
          genreIds: genreIds,
          maxPopularity: gemsMode ? Env.hiddenGemMaxPopularity : null,
          maxYear: gemsMode ? Env.hiddenGemMaxYear : null,
          minYear: gemsMode ? null : 1995,
        );
        for (final movie in moodMovies) {
          if (isRecent(movie)) collected[movie.id] = movie;
        }
      }
    }

    // 3. Fallback — trending if we don't have enough
    if (collected.length < 15) {
      final trending = await TmdbService.getTrending();
      for (final movie in trending) {
        collected[movie.id] = movie;
      }
    }

    // 4. Filter: remove already-swiped, require poster
    var filtered = collected.values
        .where(
          (m) => !seenIds.contains(m.id) && m.posterPath != null,
        )
        .toList();

    // 5. Apply hidden gem filter if gems mode
    if (gemsMode) {
      filtered = filtered
          .where(
            (m) =>
                m.popularity < Env.hiddenGemMaxPopularity &&
                m.releaseYear < Env.hiddenGemMaxYear,
          )
          .toList();

      // Fallback to gems-mode discover if still too thin
      if (filtered.length < 10) {
        final gemsDiscover = await TmdbService.discoverMovies(
          genreIds: [18, 878, 9648, 53],
          maxPopularity: Env.hiddenGemMaxPopularity,
          maxYear: Env.hiddenGemMaxYear,
          page: 2,
        );
        for (final m in gemsDiscover) {
          if (!seenIds.contains(m.id) && m.posterPath != null) {
            filtered.add(m);
          }
        }
      }
    }

    // 6. De-duplicate and cap at deck size
    final unique = <int, MovieModel>{};
    for (final m in filtered) {
      unique[m.id] = m;
    }

    final finalDeck = unique.values.toList();
    finalDeck.shuffle(); // Shuffle randomly first

    if (!gemsMode) {
      // Push older movies (1995-2010) to the back of the deck
      final newMovies = finalDeck.where((m) => m.releaseYear >= 2010).toList();
      final oldMovies = finalDeck.where((m) => m.releaseYear < 2010).toList();
      
      finalDeck.clear();
      finalDeck.addAll(newMovies);
      finalDeck.addAll(oldMovies);
    }

    return finalDeck.take(_deckSize).toList();
  }
}
