import '../config/env.dart';
import '../config/mood_config.dart';
import '../models/media_item.dart';
import '../models/movie_model.dart';
import '../models/tv_model.dart';
import '../services/hive_service.dart';
import '../services/tmdb_service.dart';

/// Controls which media types are included in the swipe deck.
enum MediaFilter {
  moviesOnly,
  tvOnly,
  both,
}

/// The recommendation engine. Builds a curated swipe deck from taste seeds,
/// mood, and hidden gem filters. This is the core business logic of Pickd.
class DiscoveryService {
  static const _deckSize = 30;

  /// Builds a full swipe deck from the user's taste + mood preferences.
  ///
  /// Returns a [List<MediaItem>] that can contain both movies and TV series
  /// depending on [filter]. Defaults to [MediaFilter.moviesOnly] for
  /// backward compatibility with existing taste-profile logic.
  static Future<List<MediaItem>> buildDeck({
    required List<int> tasteSeedMovieIds,
    required List<int> tasteSeedTvIds,
    required List<String> moodIds,
    bool gemsMode = false,
    MediaFilter filter = MediaFilter.moviesOnly,
  }) async {
    final seenIds = HiveService.getSwipeHistory();
    final profile = HiveService.getProfile();

    // Run movie and TV pipelines concurrently when needed
    final results = await Future.wait([
      if (filter == MediaFilter.moviesOnly || filter == MediaFilter.both)
        _buildMoviePipeline(
          tasteSeedIds: tasteSeedMovieIds,
          moodIds: moodIds,
          gemsMode: gemsMode,
          seenIds: seenIds,
          allowOldMovies: profile.allowOldMovies,
        )
      else
        Future.value(<MediaItem>[]),
      if (filter == MediaFilter.tvOnly || filter == MediaFilter.both)
        _buildTvPipeline(
          tasteSeedTvIds: tasteSeedTvIds,
          moodIds: moodIds,
          gemsMode: gemsMode,
          seenIds: seenIds,
          allowOldMovies: profile.allowOldMovies,
        )
      else
        Future.value(<MediaItem>[]),
    ]);

    final movieItems = results[0];
    final tvItems = results[1];

    // Interleave movies and TV — every 3rd card is a TV show in "both" mode
    final merged = <MediaItem>[];
    if (filter == MediaFilter.both) {
      int mi = 0, ti = 0;
      while (merged.length < _deckSize) {
        final wantTv = (merged.length + 1) % 3 == 0;
        if (wantTv && ti < tvItems.length) {
          merged.add(tvItems[ti++]);
        } else if (mi < movieItems.length) {
          merged.add(movieItems[mi++]);
        } else if (ti < tvItems.length) {
          merged.add(tvItems[ti++]);
        } else {
          break; // both lists exhausted
        }
      }
    } else {
      merged.addAll(movieItems);
      merged.addAll(tvItems);
    }

    // De-duplicate by ID and cap at deck size
    final seen = <int>{};
    final finalDeck = <MediaItem>[];
    for (final item in merged) {
      if (seen.add(item.id)) finalDeck.add(item);
      if (finalDeck.length >= _deckSize) break;
    }

    return finalDeck;
  }

  // ─── Movie Pipeline ───────────────────────────────────────────

  static Future<List<MediaItem>> _buildMoviePipeline({
    required List<int> tasteSeedIds,
    required List<String> moodIds,
    required bool gemsMode,
    required Set<int> seenIds,
    required bool allowOldMovies,
  }) async {
    final collected = <int, MovieModel>{};

    final selectedMoods = kMoods.where((m) => moodIds.contains(m.id));
    Set<int> moodGenreIds = selectedMoods.expand((m) => m.genreIds).toSet();

    if (moodGenreIds.isEmpty && tasteSeedIds.isNotEmpty) {
      final seedsToUse = tasteSeedIds.take(3).toList();
      final seedDetails = await Future.wait(seedsToUse.map(TmdbService.getMovieDetails));
      for (final seed in seedDetails) {
        if (seed != null) {
          moodGenreIds.addAll(seed.genreIds);
        }
      }
    }

    bool isRecent(MovieModel movie) {
      if (!allowOldMovies && movie.releaseYear <= 1990) return false;
      if (gemsMode) return true;
      if (movie.releaseDate?.isEmpty ?? true) return false;
      return true;
    }

    // 1. Recommendations + similar from taste seeds
    if (tasteSeedIds.isNotEmpty) {
      final seedsToUse = tasteSeedIds.take(3).toList();

      final [recs, similar] = await Future.wait([
        Future.wait(seedsToUse.map(TmdbService.getRecommendations)),
        Future.wait(seedsToUse.map(TmdbService.getSimilar)),
      ]);

      for (final list in [...recs, ...similar]) {
        for (final movie in list) {
          if (!isRecent(movie)) continue;
          if (moodGenreIds.isEmpty ||
              movie.genreIds.any((id) => moodGenreIds.contains(id))) {
            collected[movie.id] = movie;
          }
        }
      }
    }

    // 2. Mood-based discover
    if (moodIds.isNotEmpty) {
      final genreIds =
          kMoods.where((m) => moodIds.contains(m.id)).expand((m) => m.genreIds).toList();

      if (genreIds.isNotEmpty) {
        final moodMovies = await TmdbService.discoverMovies(
          genreIds: genreIds,
          maxPopularity: gemsMode ? Env.hiddenGemMaxPopularity : null,
          maxYear: gemsMode ? Env.hiddenGemMaxYear : null,
          minYear: (gemsMode || allowOldMovies) ? null : 1991,
        );
        for (final movie in moodMovies) {
          if (isRecent(movie)) collected[movie.id] = movie;
        }
      }
    }

    // 3. Fallback — trending
    if (collected.length < 15) {
      final trending = await TmdbService.getTrending();
      for (final movie in trending) {
        if (moodGenreIds.isEmpty ||
            movie.genreIds.any((id) => moodGenreIds.contains(id))) {
          collected[movie.id] = movie;
        }
      }
    }

    // 4. Filter: remove seen, require poster
    var filtered = collected.values
        .where((m) => !seenIds.contains(m.id) && m.posterPath != null)
        .toList();

    // 5. Gems filter
    if (gemsMode) {
      filtered = filtered
          .where((m) =>
              m.popularity < Env.hiddenGemMaxPopularity &&
              m.releaseYear < Env.hiddenGemMaxYear)
          .toList();

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

    // 6. Sort: newer first, then shuffle within groups
    filtered.shuffle();
    if (!gemsMode) {
      final newMovies = filtered.where((m) => m.releaseYear >= 2010).toList();
      final oldMovies = filtered.where((m) => m.releaseYear < 2010).toList();
      filtered = [...newMovies, ...oldMovies];
    }

    return filtered
        .take(_deckSize)
        .map((m) => MediaItem.movie(m))
        .toList();
  }

  // ─── TV Pipeline ──────────────────────────────────────────────

  static Future<List<MediaItem>> _buildTvPipeline({
    required List<int> tasteSeedTvIds,
    required List<String> moodIds,
    required bool gemsMode,
    required Set<int> seenIds,
    required bool allowOldMovies,
  }) async {
    final collected = <int, TvModel>{};

    final selectedMoods = kMoods.where((m) => moodIds.contains(m.id));
    Set<int> moodGenreIds = selectedMoods.expand((m) => m.genreIds).toSet();

    if (moodGenreIds.isEmpty && tasteSeedTvIds.isNotEmpty) {
      final seedsToUse = tasteSeedTvIds.take(3).toList();
      final seedDetails = await Future.wait(seedsToUse.map(TmdbService.getTvDetails));
      for (final seed in seedDetails) {
        if (seed != null) {
          moodGenreIds.addAll(seed.genreIds);
        }
      }
    }

    bool isRecent(TvModel show) {
      if (!allowOldMovies && show.airYear <= 1990) return false;
      if (gemsMode) return true;
      if (show.firstAirDate?.isEmpty ?? true) return false;
      return true;
    }

    // 1. Recommendations + similar from taste seeds
    if (tasteSeedTvIds.isNotEmpty) {
      final seedsToUse = tasteSeedTvIds.take(3).toList();

      final [recs, similar] = await Future.wait([
        Future.wait(seedsToUse.map(TmdbService.getTvRecommendations)),
        Future.wait(seedsToUse.map(TmdbService.getTvSimilar)),
      ]);

      for (final list in [...recs, ...similar]) {
        for (final show in list) {
          if (!isRecent(show)) continue;
          if (moodGenreIds.isEmpty ||
              show.genreIds.any((id) => moodGenreIds.contains(id))) {
            collected[show.id] = show;
          }
        }
      }
    }

    // 2. Mood-based TV discover
    if (moodIds.isNotEmpty) {
      final genreIds =
          kMoods.where((m) => moodIds.contains(m.id)).expand((m) => m.genreIds).toList();

      if (genreIds.isNotEmpty) {
        final shows = await TmdbService.discoverTv(
          genreIds: genreIds,
          maxPopularity: gemsMode ? Env.hiddenGemMaxPopularity : null,
          maxYear: gemsMode ? Env.hiddenGemMaxYear : null,
          minYear: (gemsMode || allowOldMovies) ? null : 1991,
        );
        for (final show in shows) {
          collected[show.id] = show;
        }
      }
    }

    // 3. Fallback — trending TV
    if (collected.length < 15) {
      final trending = await TmdbService.getTrendingTv();
      for (final show in trending) {
        if (moodGenreIds.isEmpty ||
            show.genreIds.any((id) => moodGenreIds.contains(id))) {
          collected[show.id] = show;
        }
      }
    }

    // 4. Filter: remove seen, require poster
    var filtered = collected.values
        .where((s) => !seenIds.contains(s.id) && s.posterPath != null)
        .toList();

    // 5. Gems filter for TV
    if (gemsMode) {
      filtered = filtered
          .where((s) =>
              s.popularity < Env.hiddenGemMaxPopularity &&
              s.airYear < Env.hiddenGemMaxYear)
          .toList();
    }

    filtered.shuffle();

    return filtered
        .take(_deckSize)
        .map((s) => MediaItem.tv(s))
        .toList();
  }
}
