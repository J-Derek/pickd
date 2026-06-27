// Environment configuration - API keys loaded via --dart-define
class Env {
  static const tmdbReadAccessToken = String.fromEnvironment(
    'TMDB_TOKEN',
    defaultValue: '',
  );

  static const tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const tmdbImageBaseW500 = 'https://image.tmdb.org/t/p/w500';
  static const tmdbImageBaseOriginal = 'https://image.tmdb.org/t/p/original';
  static const youtubeBaseUrl = 'https://www.youtube.com/watch?v=';

  // Hidden gem thresholds (from CONTEXT.md)
  static const hiddenGemMaxPopularity = 30.0;
  static const hiddenGemMaxYear = 2020;
}
