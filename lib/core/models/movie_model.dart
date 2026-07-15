import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class MovieModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? posterPath;

  @HiveField(3)
  final String? backdropPath;

  @HiveField(4)
  final String overview;

  @HiveField(5)
  final String? releaseDate;

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

  MovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    this.releaseDate,
    required this.voteAverage,
    required this.popularity,
    required this.genreIds,
    this.trailerKey,
    this.watchProviderLogoPath,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    String? logoPath;
    try {
      logoPath = json['watch/providers']['results']['US']['flatrate'][0]['logo_path'] as String?;
    } catch (_) {}

    return MovieModel(
      id: json['id'] as int,
      title: (json['title'] ?? 'Unknown') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: (json['overview'] ?? '') as String,
      releaseDate: json['release_date'] as String?,
      voteAverage: ((json['vote_average'] ?? 0) as num).toDouble(),
      popularity: ((json['popularity'] ?? 0) as num).toDouble(),
      genreIds: ((json['genre_ids'] ?? []) as List)
          .map((e) => e as int)
          .toList(),
      watchProviderLogoPath: logoPath,
    );
  }

  String get posterUrl =>
      posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : '';

  String get backdropUrl =>
      backdropPath != null
          ? 'https://image.tmdb.org/t/p/original$backdropPath'
          : '';

  int get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return 0;
    return int.tryParse(releaseDate!.split('-').first) ?? 0;
  }

  String get youtubeUrl =>
      trailerKey != null
          ? 'https://www.youtube.com/watch?v=$trailerKey'
          : '';

  bool get hasTrailer => trailerKey != null && trailerKey!.isNotEmpty;

  bool get isHiddenGem => popularity < 30 && releaseYear < 2020;

  MovieModel copyWith({
    String? trailerKey,
    String? watchProviderLogoPath,
    double? voteAverage,
  }) {
    return MovieModel(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      releaseDate: releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      popularity: popularity,
      genreIds: genreIds,
      trailerKey: trailerKey ?? this.trailerKey,
      watchProviderLogoPath: watchProviderLogoPath ?? this.watchProviderLogoPath,
    );
  }
}
