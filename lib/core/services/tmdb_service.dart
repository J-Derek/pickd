import 'package:dio/dio.dart';

import '../config/env.dart';
import '../models/movie_model.dart';

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

  /// Search movies by title — used in taste profile onboarding.
  static Future<List<MovieModel>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'include_adult': false,
          'language': 'en-US',
          'page': 1,
        },
      );
      final results = response.data['results'] as List;
      return results
          .where((m) => m['poster_path'] != null)
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .take(8)
          .toList();
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
        'sort_by': 'vote_average.desc',
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

  /// Get the full movie detail.
  static Future<MovieModel?> getMovie(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: {'language': 'en-US'},
      );
      return MovieModel.fromJson(response.data as Map<String, dynamic>);
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
