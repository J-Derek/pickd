import '../config/env.dart';

class TvEpisodeModel {
  final int id;
  final int episodeNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final String? airDate;
  final double voteAverage;
  final int? runtime;

  TvEpisodeModel({
    required this.id,
    required this.episodeNumber,
    required this.name,
    required this.overview,
    this.stillPath,
    this.airDate,
    required this.voteAverage,
    this.runtime,
  });

  factory TvEpisodeModel.fromJson(Map<String, dynamic> json) {
    return TvEpisodeModel(
      id: (json['id'] ?? 0) as int,
      episodeNumber: (json['episode_number'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      stillPath: json['still_path'] as String?,
      airDate: json['air_date'] as String?,
      voteAverage: ((json['vote_average'] ?? 0) as num).toDouble(),
      runtime: json['runtime'] as int?,
    );
  }

  String get stillUrl =>
      stillPath != null && stillPath!.isNotEmpty ? '${Env.tmdbImageBaseW500}$stillPath' : '';
}

class TvSeasonModel {
  final int id;
  final int seasonNumber;
  final String name;
  final String overview;
  final String? posterPath;
  final String? airDate;
  final double voteAverage;
  final List<TvEpisodeModel> episodes;

  TvSeasonModel({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    this.posterPath,
    this.airDate,
    required this.voteAverage,
    required this.episodes,
  });

  factory TvSeasonModel.fromJson(Map<String, dynamic> json) {
    final epList = (json['episodes'] as List? ?? [])
        .map((e) => TvEpisodeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TvSeasonModel(
      id: (json['id'] ?? 0) as int,
      seasonNumber: (json['season_number'] ?? 1) as int,
      name: (json['name'] ?? 'Season') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      airDate: json['air_date'] as String?,
      voteAverage: ((json['vote_average'] ?? 0) as num).toDouble(),
      episodes: epList,
    );
  }

  String get posterUrl =>
      posterPath != null && posterPath!.isNotEmpty ? '${Env.tmdbImageBaseW500}$posterPath' : '';
}
