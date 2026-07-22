import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/tmdb_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
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
  List<MediaItem> _relatedItems = [];
  bool _loadingRelated = false;

  bool get _isTv => _item?.isTv ?? false;

  @override
  void initState() {
    super.initState();
    if (widget.movieExtra is MediaItem) {
      _item = widget.movieExtra as MediaItem;
    }
    _fetchDetails();
    _fetchTrailer();
    _fetchWatchProviders();
    _fetchRelated();
  }

  Future<void> _fetchDetails() async {
    final isTvItem = _item?.isTv ?? false;
    
    if (isTvItem) {
      final details = await TmdbService.getTvDetails(widget.movieId);
      if (mounted && details != null) {
        setState(() => _item = MediaItem.tv(details));
      }
    } else {
      final details = await TmdbService.getMovieDetails(widget.movieId);
      if (mounted && details != null) {
        setState(() => _item = MediaItem.movie(details));
      }
    }
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

  Future<void> _fetchRelated() async {
    setState(() => _loadingRelated = true);
    try {
      final isTvItem = _item?.isTv ?? false;
      List<MediaItem> related = [];
      if (isTvItem) {
        final shows = await TmdbService.getTvRecommendations(widget.movieId);
        related = shows.map((s) => MediaItem.tv(s)).toList();
      } else {
        final movies = await TmdbService.getRecommendations(widget.movieId);
        related = movies.map((m) => MediaItem.movie(m)).toList();
      }
      if (mounted) {
        setState(() {
          _relatedItems = related.where((i) => i.posterPath != null && i.id != widget.movieId).toList();
          _loadingRelated = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRelated = false);
    }
  }

  void _openTrailer() {
    if (_trailerKey == null) return;
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _InAppTrailerSheet(videoId: _trailerKey!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final isInWatchlist =
        item != null ? ref.watch(isInWatchlistProvider(item.mediaKey)) : false;

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
                color: Colors.transparent,
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.zero,
              ),
              child: const Text(
                'TV SERIES',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
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
                      // Hard stark border below image
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: AppTheme.bgElevated,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.bgElevated,
                            border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                  if (item.year > 0)
                                    Text(
                                      '${item.year}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
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
                                     ),
                                   ),
                                  if (item.watchProviderLogoUrl != null) ...[
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () async {
                                        if (item.watchProviderLink != null) {
                                          final uri = Uri.parse(item.watchProviderLink!);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri);
                                          }
                                        }
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: item.watchProviderLogoUrl!,
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
                          _WatchProviderSection(
                            providers: _watchProviders,
                            providerLink: item.watchProviderLink,
                          ),
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
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _openTrailer,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgElevated,
                                  borderRadius: BorderRadius.zero,
                                  border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                        Icon(
                                          Icons.play_circle_filled,
                                          color: AppTheme.textPrimary,
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
                          ),
                        const SizedBox(height: 16),

                        // ── Watchlist CTA ────────────────────────────
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              if (isInWatchlist) {
                                ref
                                    .read(watchlistProvider.notifier)
                                    .remove(item.mediaKey);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Removed from Watchlist', style: TextStyle(color: AppTheme.textInverse)),
                                      backgroundColor: AppTheme.bgSurface,
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        textColor: AppTheme.accentPrimary,
                                        onPressed: () => ref.read(watchlistProvider.notifier).addMedia(item),
                                      ),
                                    ),
                                  );
                                }
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
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to Watchlist', style: TextStyle(color: AppTheme.textInverse)),
                                      backgroundColor: AppTheme.accentPrimary,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isInWatchlist
                                    ? AppTheme.bgElevated
                                    : AppTheme.accentPrimary,
                                borderRadius: BorderRadius.zero,
                                border: Border.all(
                                  color: isInWatchlist
                                      ? AppTheme.textMuted.withValues(alpha: 0.3)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                      Icon(
                                        isInWatchlist
                                            ? Icons.bookmark_remove_outlined
                                            : Icons.bookmark_add_outlined,
                                        size: 20,
                                        color: isInWatchlist
                                            ? AppTheme.textSecondary
                                            : AppTheme.textInverse,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isInWatchlist
                                            ? 'Remove from Watchlist'
                                            : 'Add to Watchlist',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isInWatchlist
                                              ? AppTheme.textPrimary
                                              : AppTheme.textInverse,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 32),

                        // ── Related Items Section ("More Like This") ──
                        if (_loadingRelated) ...[
                          const SizedBox(height: 24),
                          const Center(
                            child: CircularProgressIndicator(color: AppTheme.accentPrimary),
                          ),
                        ] else if (_relatedItems.isNotEmpty) ...[
                          const Text(
                            'More Like This',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _relatedItems.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final relatedItem = _relatedItems[index];
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/movie/${relatedItem.id}', extra: relatedItem);
                                  },
                                  child: SizedBox(
                                    width: 115,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: relatedItem.posterUrl,
                                            height: 145,
                                            width: 115,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(
                                              color: AppTheme.bgElevated,
                                            ),
                                            errorWidget: (_, __, ___) => Container(
                                              color: AppTheme.bgElevated,
                                              child: const Icon(Icons.movie_rounded, color: AppTheme.textMuted),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          relatedItem.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: AppTheme.textPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${relatedItem.year > 0 ? relatedItem.year : ''}  ⭐ ${relatedItem.voteAverage.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: AppTheme.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── In-App Trailer Player Sheet ──────────────────────────────────────────────

class _InAppTrailerSheet extends StatefulWidget {
  final String videoId;
  const _InAppTrailerSheet({required this.videoId});

  @override
  State<_InAppTrailerSheet> createState() => _InAppTrailerSheetState();
}

class _InAppTrailerSheetState extends State<_InAppTrailerSheet> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
        left: 12,
        right: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Where to Watch section widget ────────────────────────────────────────────

class _WatchProviderSection extends StatefulWidget {
  final Map<String, List<String>> providers;
  final String? providerLink;

  const _WatchProviderSection({required this.providers, this.providerLink});

  @override
  State<_WatchProviderSection> createState() => _WatchProviderSectionState();
}

class _WatchProviderSectionState extends State<_WatchProviderSection> {
  String? _clickedProvider;

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
          if (widget.providers.containsKey(type)) ...[
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
              children: widget.providers[type]!
                  .map(
                    (name) {
                      final isClicked = _clickedProvider == name;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (widget.providerLink != null) {
                              HapticFeedback.lightImpact();
                              setState(() => _clickedProvider = name);
                              
                              showCustomSnackBar(
                                context,
                                message: 'Opening $name...',
                                isSuccess: true,
                                duration: const Duration(seconds: 2),
                              );
                              
                              final uri = Uri.parse(widget.providerLink!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          splashColor: _typeColors[type]?.withValues(alpha: 0.2),
                          highlightColor: _typeColors[type]?.withValues(alpha: 0.1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isClicked ? _typeColors[type] : AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.providerLink != null
                                    ? _typeColors[type]?.withValues(alpha: isClicked ? 1.0 : 0.3) ?? AppTheme.bgMuted
                                    : AppTheme.bgMuted,
                              ),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: isClicked ? FontWeight.w700 : FontWeight.w500,
                                color: isClicked ? AppTheme.textInverse : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
      ],
    );
  }
}
