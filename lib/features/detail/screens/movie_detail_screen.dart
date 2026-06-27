import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/services/tmdb_service.dart';
import '../../../core/widgets/genre_chip.dart';
import '../../watchlist/providers/watchlist_provider.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final int movieId;
  final Object? movieExtra;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    this.movieExtra,
  });

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  MovieModel? _movie;
  String? _trailerKey;
  bool _loadingTrailer = false;

  @override
  void initState() {
    super.initState();
    if (widget.movieExtra is MovieModel) {
      _movie = widget.movieExtra as MovieModel;
    }
    _fetchTrailer();
  }

  Future<void> _fetchTrailer() async {
    setState(() => _loadingTrailer = true);
    final key = await TmdbService.getTrailerKey(widget.movieId);
    if (mounted) {
      setState(() {
        _trailerKey = key;
        _loadingTrailer = false;
      });
    }
  }

  Future<void> _openTrailer() async {
    if (_trailerKey == null) return;
    HapticFeedback.mediumImpact();
    final url = Uri.parse('https://www.youtube.com/watch?v=$_trailerKey');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie;
    final isInWatchlist =
        movie != null ? ref.watch(isInWatchlistProvider(movie.id)) : false;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      body: movie == null
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentPrimary),
            )
          : CustomScrollView(
              slivers: [
                // Backdrop hero
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        width: double.infinity,
                        child: movie.backdropPath != null
                            ? CachedNetworkImage(
                                imageUrl: movie.backdropUrl,
                                fit: BoxFit.cover,
                              )
                            : movie.posterPath != null
                                ? CachedNetworkImage(
                                    imageUrl: movie.posterUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: AppTheme.bgSurface),
                      ),
                      // Bottom fade
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 200,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.bgPrimary,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Genre chips
                        if (movie.genreIds.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: movie.genreIds
                                .take(4)
                                .map((id) => GenreChip(genreId: id))
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          movie.title,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Meta row
                        Row(
                          children: [
                            if (movie.releaseYear > 0)
                              Text(
                                '${movie.releaseYear}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.star_rounded,
                              color: AppTheme.accentPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (movie.isHiddenGem) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.gemsBadgeGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '💎 Hidden Gem',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Overview
                        if (movie.overview.isNotEmpty) ...[
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.overview,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                        // Trailer button
                        if (_loadingTrailer)
                          Center(
                            child: const CircularProgressIndicator(
                              color: AppTheme.accentPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        else if (_trailerKey != null)
                          GestureDetector(
                            onTap: _openTrailer,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.bgSurface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.bgMuted),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.play_circle_filled,
                                    color: AppTheme.accentSecondary,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Watch Trailer on YouTube',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Watchlist CTA
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (isInWatchlist) {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .remove(movie.id);
                            } else {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .add(movie);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInWatchlist
                                ? AppTheme.bgSurface
                                : AppTheme.accentPrimary,
                            foregroundColor: isInWatchlist
                                ? AppTheme.textSecondary
                                : AppTheme.textInverse,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: isInWatchlist
                                  ? const BorderSide(color: AppTheme.bgMuted)
                                  : BorderSide.none,
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isInWatchlist
                                    ? Icons.bookmark_remove_outlined
                                    : Icons.bookmark_add_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isInWatchlist
                                    ? 'Remove from Watchlist'
                                    : 'Add to Watchlist',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
