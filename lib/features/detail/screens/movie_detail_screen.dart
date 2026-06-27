import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/tmdb_service.dart';
import '../../../core/widgets/genre_chip.dart';
import '../../watchlist/providers/watchlist_provider.dart';

/// Detail screen for any MediaItem — works for both movies and TV series.
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
  MediaItem? _item;
  String? _trailerKey;
  bool _loadingTrailer = false;
  Map<String, List<String>> _watchProviders = {};
  bool _loadingProviders = false;

  bool get _isTv => _item?.isTv ?? false;

  @override
  void initState() {
    super.initState();
    if (widget.movieExtra is MediaItem) {
      _item = widget.movieExtra as MediaItem;
    }
    _fetchTrailer();
    _fetchWatchProviders();
  }

  Future<void> _fetchTrailer() async {
    setState(() => _loadingTrailer = true);
    final key = _isTv
        ? await TmdbService.getTvTrailerKey(widget.movieId)
        : await TmdbService.getTrailerKey(widget.movieId);
    if (mounted) {
      setState(() {
        _trailerKey = key;
        _loadingTrailer = false;
      });
    }
  }

  Future<void> _fetchWatchProviders() async {
    setState(() => _loadingProviders = true);
    final providers = _isTv
        ? await TmdbService.getTvWatchProviders(widget.movieId)
        : await TmdbService.getMovieWatchProviders(widget.movieId);
    if (mounted) {
      setState(() {
        _watchProviders = providers;
        _loadingProviders = false;
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
    final item = _item;
    final isInWatchlist =
        item != null ? ref.watch(isInWatchlistProvider(item.id)) : false;

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
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        actions: [
          if (item?.isTv == true)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'TV SERIES',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
      body: item == null
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
                        child: item.backdropPath != null
                            ? CachedNetworkImage(
                                imageUrl: item.backdropUrl,
                                fit: BoxFit.cover,
                              )
                            : item.posterPath != null
                                ? CachedNetworkImage(
                                    imageUrl: item.posterUrl,
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
                          decoration: const BoxDecoration(
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
                        if (item.genreIds.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: item.genreIds
                                .take(4)
                                .map((id) => GenreChip(genreId: id))
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          item.title,
                          style: const TextStyle(
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
                            if (item.year > 0)
                              Text(
                                '${item.year}',
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
                              item.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (item.isHiddenGem) ...[
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
                                  'Hidden Gem',
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
                        if (item.overview.isNotEmpty) ...[
                          const Text(
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
                            item.overview,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // ── Where to Watch ──────────────────────────
                        if (_loadingProviders)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppTheme.accentPrimary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        else if (_watchProviders.isNotEmpty) ...[
                          const Text(
                            'Where to Watch',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _WatchProviderSection(providers: _watchProviders),
                          const SizedBox(height: 24),
                        ],

                        // ── Trailer button ───────────────────────────
                        if (_loadingTrailer)
                          const Center(
                            child: CircularProgressIndicator(
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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

                        // ── Watchlist CTA ────────────────────────────
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (isInWatchlist) {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .remove(item.id);
                            } else {
                              // Route to correct watchlist by type
                              switch (item) {
                                case MovieItem(:final movie):
                                  ref
                                      .read(watchlistProvider.notifier)
                                      .add(movie);
                                case TvItem(:final show):
                                  ref
                                      .read(watchlistProvider.notifier)
                                      .addTv(show);
                              }
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

// ── Where to Watch section widget ────────────────────────────────────────────

class _WatchProviderSection extends StatelessWidget {
  final Map<String, List<String>> providers;

  const _WatchProviderSection({required this.providers});

  static const _typeLabels = {
    'flatrate': 'Stream',
    'rent': 'Rent',
    'buy': 'Buy',
  };

  static const _typeColors = {
    'flatrate': AppTheme.accentPrimary,
    'rent': Color(0xFF6B8AFF),
    'buy': Color(0xFF9B6BFF),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final type in ['flatrate', 'rent', 'buy'])
          if (providers.containsKey(type)) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _typeColors[type],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _typeLabels[type]!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _typeColors[type],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: providers[type]!
                  .map(
                    (name) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.bgMuted),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
      ],
    );
  }
}
