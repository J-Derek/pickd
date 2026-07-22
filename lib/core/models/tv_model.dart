import 'package:hive/hive.dart';
import '../config/env.dart';

part 'tv_model.g.dart';

/// Represents a TV series fetched from TMDB.
/// Stored in a separate Hive box so it can be persisted to the watchlist.
@HiveType(typeId: 2)
class TvModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? posterPath;

  @HiveField(3)
  final String? backdropPath;

  @HiveField(4)
  final String overview;

  @HiveField(5)
  final String? firstAirDate;

  @HiveField(6)
  final double voteAverage;

  @HiveField(7)
  final double popularity;

  @HiveField(8)
  final List<int> genreIds;

  @HiveField(9)
  final String? trailerKey;

  @HiveField(10)
  final String? watchProviderLogoPath;

  final String? watchProviderLink; // Not stored in Hive

  TvModel({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    this.firstAirDate,
    required this.voteAverage,
    required this.popularity,
    required this.genreIds,
    this.trailerKey,
    this.watchProviderLogoPath,
    this.watchProviderLink,
  });

  factory TvModel.fromJson(Map<String, dynamic> json) {
    String? logoPath;
    String? link;
    try {
      logoPath = json['watch/providers']['results']['US']['flatrate'][0]['logo_path'] as String?;
      link = json['watch/providers']['results']['US']['link'] as String?;
    } catch (_) {}

    return TvModel(
      id: json['id'] as int,
      name: (json['name'] ?? json['title'] ?? 'Unknown') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: (json['overview'] ?? '') as String,
      firstAirDate: json['first_air_date'] as String?,
      voteAverage: ((json['vote_average'] ?? 0) as num).toDouble(),
      popularity: ((json['popularity'] ?? 0) as num).toDouble(),
      genreIds: ((json['genre_ids'] ?? []) as List)
          .map((e) => e as int)
          .toList(),
      watchProviderLogoPath: logoPath,
      watchProviderLink: link,
    );
  }

  String get posterUrl =>
      posterPath != null
          ? '${Env.tmdbImageBaseW500}$posterPath'
          : '';

  String get backdropUrl =>
      backdropPath != null
          ? '${Env.tmdbImageBaseOriginal}$backdropPath'
          : '';

  int get airYear {
    if (firstAirDate == null || firstAirDate!.isEmpty) return 0;
    return int.tryParse(firstAirDate!.split('-').first) ?? 0;
  }

  String get youtubeUrl =>
      trailerKey != null
          ? '${Env.youtubeBaseUrl}$trailerKey'
          : '';

  bool get hasTrailer => trailerKey != null && trailerKey!.isNotEmpty;

  bool get isHiddenGem =>
      popularity < Env.hiddenGemMaxPopularity &&
      airYear < Env.hiddenGemMaxYear;

  TvModel copyWith({
    String? trailerKey,
    String? watchProviderLogoPath,
    double? voteAverage,
  }) {
    return TvModel(
      id: id,
      name: name,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      firstAirDate: firstAirDate,
      voteAverage: voteAverage ?? this.voteAverage,
      popularity: popularity,
      genreIds: genreIds,
      trailerKey: trailerKey ?? this.trailerKey,
      watchProviderLogoPath: watchProviderLogoPath ?? this.watchProviderLogoPath,
    );
  }
}
