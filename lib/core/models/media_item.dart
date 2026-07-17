import 'movie_model.dart';
import 'tv_model.dart';
import '../config/env.dart';

/// A sealed class representing any swipeable media item — either a Movie or a TV Series.
///
/// This is the unified runtime type used throughout the UI and business logic.
/// Hive persistence always serializes back to [MovieModel] or [TvModel] which
/// have their own registered TypeAdapters.
///
/// Usage:
/// ```dart
/// final item = MediaItem.movie(someMovieModel);
/// final title = item.title;           // works for both variants
/// final year  = item.year;            // works for both variants
///
/// switch (item) {
///   case MovieItem(:final movie) => // handle movie
///   case TvItem(:final show)    => // handle TV show
/// }
/// ```
sealed class MediaItem {
  const MediaItem();

  // ─── Factories ───────────────────────────────────────────────
  const factory MediaItem.movie(MovieModel movie) = MovieItem;
  const factory MediaItem.tv(TvModel show) = TvItem;

  // ─── Shared accessors (work for both variants) ───────────────

  int get id => switch (this) {
        MovieItem(:final movie) => movie.id,
        TvItem(:final show) => show.id,
      };

  String get title => switch (this) {
        MovieItem(:final movie) => movie.title,
        TvItem(:final show) => show.name,
      };

  String get overview => switch (this) {
        MovieItem(:final movie) => movie.overview,
        TvItem(:final show) => show.overview,
      };

  String? get posterPath => switch (this) {
        MovieItem(:final movie) => movie.posterPath,
        TvItem(:final show) => show.posterPath,
      };

  String? get backdropPath => switch (this) {
        MovieItem(:final movie) => movie.backdropPath,
        TvItem(:final show) => show.backdropPath,
      };

  String get posterUrl => switch (this) {
        MovieItem(:final movie) => movie.posterUrl,
        TvItem(:final show) => show.posterUrl,
      };

  String get backdropUrl => switch (this) {
        MovieItem(:final movie) => movie.backdropUrl,
        TvItem(:final show) => show.backdropUrl,
      };

  double get voteAverage => switch (this) {
        MovieItem(:final movie) => movie.voteAverage,
        TvItem(:final show) => show.voteAverage,
      };

  double get popularity => switch (this) {
        MovieItem(:final movie) => movie.popularity,
        TvItem(:final show) => show.popularity,
      };

  List<int> get genreIds => switch (this) {
        MovieItem(:final movie) => movie.genreIds,
        TvItem(:final show) => show.genreIds,
      };

  String? get trailerKey => switch (this) {
        MovieItem(:final movie) => movie.trailerKey,
        TvItem(:final show) => show.trailerKey,
      };

  bool get hasTrailer => switch (this) {
        MovieItem(:final movie) => movie.hasTrailer,
        TvItem(:final show) => show.hasTrailer,
      };

  String get youtubeUrl => switch (this) {
        MovieItem(:final movie) => movie.youtubeUrl,
        TvItem(:final show) => show.youtubeUrl,
      };

  bool get isHiddenGem => switch (this) {
        MovieItem(:final movie) => movie.isHiddenGem,
        TvItem(:final show) => show.isHiddenGem,
      };

  String? get watchProviderLogoUrl {
    final path = switch (this) {
      MovieItem(:final movie) => movie.watchProviderLogoPath,
      TvItem(:final show) => show.watchProviderLogoPath,
    };
    if (path == null) return null;
    return '${Env.tmdbImageBaseW500}$path';
  }

  String? get watchProviderLink => switch (this) {
        MovieItem(:final movie) => movie.watchProviderLink,
        TvItem(:final show) => show.watchProviderLink,
      };

  /// The display year — release year for movies, air year for TV shows.
  int get year => switch (this) {
        MovieItem(:final movie) => movie.releaseYear,
        TvItem(:final show) => show.airYear,
      };

  /// True if this item is a TV series.
  bool get isTv => this is TvItem;

  /// True if this item is a movie.
  bool get isMovie => this is MovieItem;

  /// Returns a new instance with the trailer key applied.
  MediaItem withTrailerKey(String key) => switch (this) {
        MovieItem(:final movie) => MediaItem.movie(movie.copyWith(trailerKey: key)),
        TvItem(:final show) => MediaItem.tv(show.copyWith(trailerKey: key)),
      };
}

/// The movie variant of [MediaItem].
final class MovieItem extends MediaItem {
  final MovieModel movie;
  const MovieItem(this.movie);
}

/// The TV series variant of [MediaItem].
final class TvItem extends MediaItem {
  final TvModel show;
  const TvItem(this.show);
}
