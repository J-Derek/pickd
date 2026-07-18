import 'package:dio/dio.dart';

import '../config/env.dart';
import '../models/media_item.dart';
import '../models/movie_model.dart';
import '../models/tv_model.dart';

/// All TMDB API calls. Direct client-to-API, no backend.
class TmdbService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: Env.tmdbBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': 'Bearer ${Env.tmdbReadAccessToken}',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.addAll([
      _CacheInterceptor(),
      LogInterceptor(responseBody: false),
    ]);

  /// Search movies and TV series by title — used in taste profile onboarding.
  static Future<List<MediaItem>> searchMulti(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get(
        '/search/multi',
        queryParameters: {
          'query': query,
          'include_adult': false,
          'language': 'en-US',
          'page': 1,
        },
      );
      final results = response.data['results'] as List;
      final out = <MediaItem>[];
      for (final item in results) {
        if (item['poster_path'] == null) continue;
        if (item['media_type'] == 'movie') {
          out.add(MediaItem.movie(MovieModel.fromJson(item as Map<String, dynamic>)));
        } else if (item['media_type'] == 'tv') {
          out.add(MediaItem.tv(TvModel.fromJson(item as Map<String, dynamic>)));
        }
      }
      return out.take(8).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get recommendations based on a seed movie ID.
  static Future<List<MovieModel>> getRecommendations(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/recommendations',
        queryParameters: {'language': 'en-US', 'page': 1},
      );
      final results = response.data['results'] as List;
      return results
          .where((m) => m['poster_path'] != null)
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get similar movies to a seed.
  static Future<List<MovieModel>> getSimilar(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/similar',
        queryParameters: {'language': 'en-US', 'page': 1},
      );
      final results = response.data['results'] as List;
      return results
          .where((m) => m['poster_path'] != null)
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Discover movies by genre IDs with optional filters.
  static Future<List<MovieModel>> discoverMovies({
    required List<int> genreIds,
    double? maxPopularity,
    int? maxYear,
    int? minYear,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{
        'language': 'en-US',
        'with_genres': genreIds.join('|'),
        'sort_by': 'popularity.desc',
        'vote_count.gte': 100,
        'include_adult': false,
        'page': page,
      };

      if (maxPopularity != null) {
        params['popularity.lte'] = maxPopularity;
      }
      if (maxYear != null) {
        params['primary_release_date.lte'] = '$maxYear-12-31';
      }
      if (minYear != null) {
        params['primary_release_date.gte'] = '$minYear-01-01';
      }

      final response = await _dio.get(
        '/discover/movie',
        queryParameters: params,
      );
      final results = response.data['results'] as List;
      return results
          .where((m) => m['poster_path'] != null)
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get massively popular movies for the visual onboarding grid.
  static Future<List<MovieModel>> getPopularMoviesForOnboarding(int page) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'language': 'en-US',
          'sort_by': 'popularity.desc',
          'vote_count.gte': 1000,
          'include_adult': false,
          'page': page,
        },
      );
      final results = response.data['results'] as List;
      return results
          .where((m) => m['poster_path'] != null)
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get the full movie detail.
  static Future<MovieModel?> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: {
          'language': 'en-US',
          'append_to_response': 'watch/providers',
        },
      );
      return MovieModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Get the full TV detail.
  static Future<TvModel?> getTvDetails(int seriesId) async {
    try {
      final response = await _dio.get(
        '/tv/$seriesId',
        queryParameters: {
          'language': 'en-US',
          'append_to_response': 'watch/providers',
        },
      );
      return TvModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Get YouTube trailer key for a movie.
  static Future<String?> getTrailerKey(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/videos',
        queryParameters: {'language': 'en-US'},
      );
      final results = response.data['results'] as List;
      // Prefer official trailer, fallback to any YouTube video
      final trailer = results.firstWhere(
        (v) =>
            v['site'] == 'YouTube' &&
            v['type'] == 'Trailer' &&
            v['official'] == true,
        orElse: () => results.firstWhere(
          (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
          orElse: () => results.firstWhere(
            (v) => v['site'] == 'YouTube',
            orElse: () => null,
          ),
        ),
      );
      return trailer?['key'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Trending movies — used as fallback deck filler.
  static Future<List<MovieModel>> getTrending({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/trending/movie/week',
        queryParameters: {'language': 'en-US', 'page': page},
      );
      final results = response.data['results'] as List;
      return results
          .where((m) => m['poster_path'] != null)
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── TV Series Endpoints ──────────────────────────────────────

  /// Get recommendations based on a seed TV show ID.
  static Future<List<TvModel>> getTvRecommendations(int seriesId) async {
    try {
      final response = await _dio.get(
        '/tv/$seriesId/recommendations',
        queryParameters: {'language': 'en-US', 'page': 1},
      );
      final results = response.data['results'] as List;
      return results
          .where((s) => s['poster_path'] != null)
          .map((s) => TvModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get similar TV shows to a seed.
  static Future<List<TvModel>> getTvSimilar(int seriesId) async {
    try {
      final response = await _dio.get(
        '/tv/$seriesId/similar',
        queryParameters: {'language': 'en-US', 'page': 1},
      );
      final results = response.data['results'] as List;
      return results
          .where((s) => s['poster_path'] != null)
          .map((s) => TvModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Discover TV series by genre IDs with optional filters.
  static Future<List<TvModel>> discoverTv({
    required List<int> genreIds,
    double? maxPopularity,
    int? maxYear,
    int? minYear,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{
        'language': 'en-US',
        'with_genres': genreIds.join('|'),
        'sort_by': 'popularity.desc',
        'vote_count.gte': 50,
        'include_adult': false,
        'page': page,
      };

      if (maxPopularity != null) params['popularity.lte'] = maxPopularity;
      if (maxYear != null) params['first_air_date.lte'] = '$maxYear-12-31';
      if (minYear != null) params['first_air_date.gte'] = '$minYear-01-01';

      final response = await _dio.get(
        '/discover/tv',
        queryParameters: params,
      );
      final results = response.data['results'] as List;
      return results
          .where((s) => s['poster_path'] != null)
          .map((s) => TvModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get YouTube trailer key for a TV series.
  static Future<String?> getTvTrailerKey(int seriesId) async {
    try {
      final response = await _dio.get(
        '/tv/$seriesId/videos',
        queryParameters: {'language': 'en-US'},
      );
      final results = response.data['results'] as List;
      final trailer = results.firstWhere(
        (v) =>
            v['site'] == 'YouTube' &&
            v['type'] == 'Trailer' &&
            v['official'] == true,
        orElse: () => results.firstWhere(
          (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
          orElse: () => results.firstWhere(
            (v) => v['site'] == 'YouTube',
            orElse: () => null,
          ),
        ),
      );
      return trailer?['key'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Trending TV series — fallback filler for TV deck.
  static Future<List<TvModel>> getTrendingTv({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/trending/tv/week',
        queryParameters: {'language': 'en-US', 'page': page},
      );
      final results = response.data['results'] as List;
      return results
          .where((s) => s['poster_path'] != null)
          .map((s) => TvModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Watch Providers (powered by JustWatch data via TMDB) ─────

  /// Returns streaming provider info for a movie keyed by country code.
  /// Example: `providers['US']` → list of provider names like ['Netflix', 'Hulu'].
  static Future<Map<String, List<String>>> getMovieWatchProviders(
    int movieId, {
    String region = 'US',
  }) async {
    return _parseWatchProviders(
      await _fetchWatchProviders('/movie/$movieId/watch/providers', region),
    );
  }

  /// Returns streaming provider info for a TV series keyed by country code.
  static Future<Map<String, List<String>>> getTvWatchProviders(
    int seriesId, {
    String region = 'US',
  }) async {
    return _parseWatchProviders(
      await _fetchWatchProviders('/tv/$seriesId/watch/providers', region),
    );
  }

  static Future<Map<String, dynamic>?> _fetchWatchProviders(
    String path,
    String region,
  ) async {
    try {
      final response = await _dio.get(path);
      final results = response.data['results'] as Map<String, dynamic>?;
      return results?[region] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  static Map<String, List<String>> _parseWatchProviders(
    Map<String, dynamic>? regionData,
  ) {
    if (regionData == null) return {};
    final out = <String, List<String>>{};

    // flatrate = subscription (Netflix, Disney+, etc.)
    // rent / buy = transactional
    for (final type in ['flatrate', 'rent', 'buy']) {
      final providers = regionData[type] as List?;
      if (providers != null && providers.isNotEmpty) {
        out[type] = providers
            .map((p) => (p['provider_name'] as String?) ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
    }
    return out;
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  _CacheEntry(this.data, this.timestamp);
}

class _CacheInterceptor extends Interceptor {
  final Map<String, _CacheEntry> _cache = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method == 'GET') {
      final key = options.uri.toString();
      final entry = _cache[key];
      if (entry != null && DateTime.now().difference(entry.timestamp).inMinutes < 5) {
        return handler.resolve(
          Response(
            requestOptions: options,
            data: entry.data,
            statusCode: 200,
          ),
          true,
        );
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      final key = response.requestOptions.uri.toString();
      _cache[key] = _CacheEntry(response.data, DateTime.now());
    }
    handler.next(response);
  }
}
