import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/discovery_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/services/supabase_db_service.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import '../../../core/widgets/genre_chip.dart';

class GemsScreen extends ConsumerStatefulWidget {
  const GemsScreen({super.key});

  @override
  ConsumerState<GemsScreen> createState() => _GemsScreenState();
}

class _GemsScreenState extends ConsumerState<GemsScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  List<MediaItem> _gems = [];
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
      final user = ref.read(currentUserProvider);
      
      Set<String> seenKeys = HiveService.getSwipedKeys();
      if (user != null) {
        final supabaseKeys = await ref.read(supabaseDbServiceProvider).getSwipedMediaKeys(user.id);
        seenKeys = {...seenKeys, ...supabaseKeys};
      }
      
      final gems = await DiscoveryService.buildDeck(
        tasteSeedMovieIds: profile.tasteSeedMovieIds,
        tasteSeedTvIds: profile.tasteSeedTvIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: true,
        seenKeys: seenKeys,
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
      final user = ref.read(currentUserProvider);
      
      Set<String> seenKeys = HiveService.getSwipedKeys();
      if (user != null) {
        final supabaseKeys = await ref.read(supabaseDbServiceProvider).getSwipedMediaKeys(user.id);
        seenKeys = {...seenKeys, ...supabaseKeys};
      }
      
      final newGems = await DiscoveryService.buildDeck(
        tasteSeedMovieIds: profile.tasteSeedMovieIds,
        tasteSeedTvIds: profile.tasteSeedTvIds,
        moodIds: profile.selectedMoodIds,
        gemsMode: true,
        seenKeys: seenKeys,
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
                        const Row(
                          children: [
                            Text(
                              'HIDDEN GEMS',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -1,
                              ),
                            ),
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
                  Material(
                    color: AppTheme.bgSurface,
                    shape: Border.all(color: AppTheme.bgMuted, width: 2),
                    child: InkWell(
                      onTap: _loadGems,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          LucideIcons.refreshCw,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
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
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ShimmerCard(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 0,
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
            const Icon(LucideIcons.search, size: 48, color: AppTheme.textMuted),
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
          switch (movie) {
            case MovieItem(:final movie):
              ref.read(watchlistProvider.notifier).add(movie);
            case TvItem(:final show):
              ref.read(watchlistProvider.notifier).addTv(show);
          }
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
  final MediaItem movie;
  final double percentX;

  const _GemCard({required this.movie, required this.percentX});

  @override
  Widget build(BuildContext context) {
    final opacity = (percentX.abs() / 100).clamp(0.0, 1.0);
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.zero,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
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
            // Brutalist border overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    color: AppTheme.textPrimary.withValues(alpha: 0.1),
                    width: 1,
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
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: AppTheme.bgMuted, width: 1),
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
                      color: AppTheme.bgPrimary,
                      border: Border.all(color: AppTheme.accentSecondary, width: 3),
                      borderRadius: BorderRadius.zero,
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentPrimary,
                        borderRadius: BorderRadius.zero,
                      ),
                      child: const Text(
                        'HIDDEN GEM',
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
                          '${movie.year}',
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Undo (Small)
          _LabeledGlassButton(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.undo();
            },
            size: 52,
            icon: Icons.undo_rounded,
            iconColor: AppTheme.textMuted,
            label: 'UNDO',
          ),
          
          // Skip / X (Large)
          _LabeledGlassButton(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.swipe(CardSwiperDirection.left);
            },
            size: 72,
            icon: Icons.close_rounded,
            iconColor: AppTheme.accentSecondary,
            label: 'SKIP',
          ),

          // Save / Bookmark (Large)
          _LabeledGlassButton(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.swipe(CardSwiperDirection.right);
            },
            size: 72,
            icon: Icons.bookmark_add_rounded,
            iconColor: AppTheme.accentPrimary,
            label: 'SAVE',
          ),
        ],
      ),
    );
  }
}

class _LabeledGlassButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final IconData icon;
  final Color iconColor;
  final String label;
  final List<BoxShadow>? boxShadow;

  const _LabeledGlassButton({
    required this.onTap,
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.boxShadow,
  });

  @override
  State<_LabeledGlassButton> createState() => _LabeledGlassButtonState();
}

class _LabeledGlassButtonState extends State<_LabeledGlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.boxShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size / 2),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: AppTheme.glassBlur, sigmaY: AppTheme.glassBlur),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: _isPressed 
                        ? widget.iconColor.withValues(alpha: 0.3) 
                        : AppTheme.glassBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isPressed ? widget.iconColor : AppTheme.glassBorder, 
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    widget.icon, 
                    color: _isPressed ? widget.iconColor : AppTheme.textMuted, 
                    size: widget.size * 0.45,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _isPressed ? widget.iconColor : AppTheme.textMuted,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

}
