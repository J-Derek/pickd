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

  // Rich TV detail fields (not stored in Hive)
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? status;
  final String? lastAirDate;
  final List<String>? createdBy;
  final List<int>? episodeRunTime;
  final List<String>? networks;

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
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.status,
    this.lastAirDate,
    this.createdBy,
    this.episodeRunTime,
    this.networks,
  });

  factory TvModel.fromJson(Map<String, dynamic> json) {
    String? logoPath;
    String? link;
    try {
      logoPath = json['watch/providers']['results']['US']['flatrate'][0]['logo_path'] as String?;
      link = json['watch/providers']['results']['US']['link'] as String?;
    } catch (_) {}

    int? numSeasons = json['number_of_seasons'] as int?;
    int? numEpisodes = json['number_of_episodes'] as int?;
    String? showStatus = json['status'] as String?;
    String? lastAir = json['last_air_date'] as String?;
    List<String>? creators;
    if (json['created_by'] != null) {
      try {
        creators = (json['created_by'] as List)
            .map((c) => (c['name'] ?? '') as String)
            .where((n) => n.isNotEmpty)
            .toList();
      } catch (_) {}
    }
    List<int>? runtimes;
    if (json['episode_run_time'] != null) {
      try {
        runtimes = (json['episode_run_time'] as List)
            .map((r) => (r as num).toInt())
            .toList();
      } catch (_) {}
    }
    List<String>? netList;
    if (json['networks'] != null) {
      try {
        netList = (json['networks'] as List)
            .map((n) => (n['name'] ?? '') as String)
            .where((s) => s.isNotEmpty)
            .toList();
      } catch (_) {}
    }

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
      numberOfSeasons: numSeasons,
      numberOfEpisodes: numEpisodes,
      status: showStatus,
      lastAirDate: lastAir,
      createdBy: creators,
      episodeRunTime: runtimes,
      networks: netList,
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
