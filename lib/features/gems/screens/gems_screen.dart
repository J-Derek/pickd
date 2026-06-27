import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/discovery_service.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/genre_chip.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
class GemsScreen extends ConsumerStatefulWidget {
  const GemsScreen({super.key});

  @override
  ConsumerState<GemsScreen> createState() => _GemsScreenState();
}

class _GemsScreenState extends ConsumerState<GemsScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  List<MovieModel> _gems = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGems();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadGems() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = HiveService.getProfile();
      final gems = await DiscoveryService.buildDeck(
        tasteSeedIds: profile.tasteSeedMovieIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: true,
      );
      if (mounted) {
        setState(() {
          _gems = gems;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load gems. Tap to retry.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMoreGems() async {
    try {
      final profile = HiveService.getProfile();
      final newGems = await DiscoveryService.buildDeck(
        tasteSeedIds: profile.tasteSeedMovieIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: true,
      );
      if (mounted) {
        setState(() {
          final existingIds = _gems.map((e) => e.id).toSet();
          _gems.addAll(newGems.where((g) => !existingIds.contains(g.id)));
        });
      }
    } catch (e) {
      // Ignore background load errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.gemsBadgeGradient.createShader(bounds),
                              child: Text(
                                'Hidden Gems',
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('💎', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Under-the-radar picks. Popularity < 30, before 2020.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _loadGems,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.bgMuted),
                      ),
                      child: const Icon(
                        LucideIcons.refreshCw,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
            if (!_loading && _gems.isNotEmpty)
              _ActionButtons(controller: _swiperController),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ShimmerCard(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 32,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: GestureDetector(
          onTap: _loadGems,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💎', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (_gems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'No gems found for your taste.\nTry adjusting your mood.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return CardSwiper(
      controller: _swiperController,
      cardsCount: _gems.length,
      numberOfCardsDisplayed: _gems.length >= 3 ? 3 : _gems.length,
      allowedSwipeDirection:
          const AllowedSwipeDirection.only(left: true, right: true),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      scale: 0.92,
      cardBuilder: (context, index, percentX, percentY) {
        if (index >= _gems.length) return const SizedBox.shrink();
        final movie = _gems[index];
        return GestureDetector(
          onTap: () =>
              context.push('/movie/${movie.id}', extra: movie),
          child: _GemCard(movie: movie, percentX: percentX.toDouble()),
        );
      },
      onSwipe: (prev, curr, dir) {
        if (prev >= _gems.length) return true;
        final movie = _gems[prev];
        if (dir == CardSwiperDirection.right) {
          ref.read(watchlistProvider.notifier).add(movie);
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        final currentIndex = curr ?? prev + 1;
        if (_gems.length - currentIndex < 5) _loadMoreGems();
        return true;
      },
    );
  }
}

class _GemCard extends StatelessWidget {
  final MovieModel movie;
  final double percentX;

  const _GemCard({required this.movie, required this.percentX});

  @override
  Widget build(BuildContext context) {
    final opacity = (percentX.abs() / 100).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2FBE).withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            movie.posterPath != null
                ? CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                  )
                : Container(color: AppTheme.bgSurface),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.3, 1.0],
                    colors: [Colors.transparent, Colors.transparent, Color(0xEA080808)],
                  ),
                ),
              ),
            ),
            // Gem shimmer border
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF7B2FBE).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            if (percentX > 0)
              Positioned(
                top: 24,
                left: 24,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accentPrimary, width: 2.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'WATCH',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            if (percentX < 0)
              Positioned(
                top: 24,
                right: 24,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accentSecondary, width: 2.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gem badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    const SizedBox(height: 8),
                    if (movie.genreIds.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: movie.genreIds.take(3)
                            .map((id) => GenreChip(genreId: id))
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${movie.releaseYear}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(LucideIcons.star,
                            color: AppTheme.accentPrimary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final CardSwiperController controller;

  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.swipe(CardSwiperDirection.left);
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.accentSecondary.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(LucideIcons.x,
                  color: AppTheme.accentSecondary, size: 28),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.undo();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.bgMuted),
              ),
              child: const Icon(LucideIcons.rotateCcw,
                  color: AppTheme.textMuted, size: 20),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.swipe(CardSwiperDirection.right);
            },
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: AppTheme.gemsBadgeGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B2FBE).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              child: const Icon(LucideIcons.bookmarkPlus,
                  color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}
