import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/discovery_service.dart';
import '../../../core/widgets/genre_chip.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../providers/swipe_provider.dart';
import 'auth_gate_sheet.dart';


class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  bool _gateShown = false;
  MediaFilter _activeFilter = MediaFilter.moviesOnly;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(swipeDeckProvider.notifier).loadDeck();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _showAuthGate() {
    if (_gateShown) return;
    _gateShown = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => const AuthGateSheet(),
    ).then((_) {
      _gateShown = false;
      ref.read(swipeDeckProvider.notifier).resetSwipeGate();
    });
  }

  void _onFilterTap(MediaFilter filter) {
    if (_activeFilter == filter) return;
    HapticFeedback.selectionClick();
    setState(() => _activeFilter = filter);
    ref.read(swipeDeckProvider.notifier).setFilter(filter);
  }

  @override
  Widget build(BuildContext context) {
    final deckState = ref.watch(swipeDeckProvider);

    // Trigger swipe gate at exactly 5 swipes
    ref.listen<SwipeDeckState>(swipeDeckProvider, (prev, next) {
      if (next.hasReachedSwipeGate && !(prev?.hasReachedSwipeGate ?? false)) {
        _showAuthGate();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildFilterToggle(),
            Expanded(child: _buildBody(deckState)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Text(
            'pickd',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentPrimary,
            ),
          ),
          const Spacer(),
          // Edit Profile
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/onboarding/mood');
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.bgMuted),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Refresh deck
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(swipeDeckProvider.notifier).loadDeck();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.bgMuted),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    const segments = [
      (MediaFilter.moviesOnly, 'Movies'),
      (MediaFilter.both, 'Both'),
      (MediaFilter.tvOnly, 'TV Shows'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.bgMuted),
        ),
        child: Row(
          children: segments.map((seg) {
            final (filter, label) = seg;
            final isActive = _activeFilter == filter;
            final isFirst = filter == MediaFilter.moviesOnly;
            final isLast = filter == MediaFilter.tvOnly;

            return Expanded(
              child: GestureDetector(
                onTap: () => _onFilterTap(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.fromLTRB(
                    isFirst ? 3 : 0,
                    3,
                    isLast ? 3 : 0,
                    3,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.accentPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? AppTheme.textInverse
                          : AppTheme.textSecondary,
                    ),
                    child: Text(label),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody(SwipeDeckState deckState) {
    if (deckState.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ShimmerCard(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 32,
        ),
      );
    }

    if (deckState.error != null) {
      return Center(
        child: GestureDetector(
          onTap: () => ref.read(swipeDeckProvider.notifier).loadDeck(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😵', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                deckState.error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (deckState.isDeckEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'You\'ve seen everything!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap below to load more',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(swipeDeckProvider.notifier).loadDeck(),
              child: const Text('Load more'),
            ),
          ],
        ),
      );
    }

    final deck = deckState.deck;

    return Column(
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: CardSwiper(
            controller: _swiperController,
            cardsCount: deck.length,
            numberOfCardsDisplayed: deck.length >= 3 ? 3 : deck.length,
            allowedSwipeDirection:
                const AllowedSwipeDirection.only(left: true, right: true),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            scale: 0.92,
            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
              if (index >= deck.length) return const SizedBox.shrink();
              return _SwipeCard(
                movie: deck[index],
                percentX: percentThresholdX.toDouble(),
                onTap: () => context.push('/movie/${deck[index].id}',
                    extra: deck[index]),
              );
            },
            onSwipe: (prev, curr, dir) {
              final item = deck[prev];
              final liked = dir == CardSwiperDirection.right;
              if (liked) {
                HapticFeedback.mediumImpact();
              } else {
                HapticFeedback.lightImpact();
              }
              ref.read(swipeDeckProvider.notifier).onSwiped(item, liked);
              return true;
            },
            onUndo: (prev, curr, dir) {
              if (prev == null) return false;
              final item = deck[prev];
              final wasLiked = dir == CardSwiperDirection.right;
              ref.read(swipeDeckProvider.notifier).onUndo(item, wasLiked);
              HapticFeedback.lightImpact();
              return true;
            },
          ),
        ),
        // Action buttons
        _ActionButtons(controller: _swiperController),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SwipeCard extends StatelessWidget {
  final MediaItem movie;
  final double percentX;
  final VoidCallback onTap;

  const _SwipeCard({
    required this.movie,
    required this.percentX,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final watchIndicatorOpacity = (percentX.abs() / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image
              movie.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppTheme.bgSurface,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.bgSurface,
                        child: const Icon(
                          Icons.movie,
                          color: AppTheme.textMuted,
                          size: 48,
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.bgSurface,
                      child: const Icon(
                        Icons.movie,
                        color: AppTheme.textMuted,
                        size: 64,
                      ),
                    ),

              // Bottom gradient overlay
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.3, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xE6080808),
                      ],
                    ),
                  ),
                ),
              ),

              // TV badge (top-right)
              if (movie.isTv)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bgElevated,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TV',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              // WATCH indicator (right swipe)
              if (percentX > 0)
                Positioned(
                  top: 24,
                  left: 24,
                  child: Opacity(
                    opacity: watchIndicatorOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.accentPrimary,
                          width: 2.5,
                        ),
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

              // SKIP indicator (left swipe)
              if (percentX < 0)
                Positioned(
                  top: 24,
                  right: 24,
                  child: Opacity(
                    opacity: watchIndicatorOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.accentSecondary,
                          width: 2.5,
                        ),
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

              // Card content (bottom)
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
                      // Genre chips
                      if (movie.genreIds.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: movie.genreIds
                              .take(3)
                              .map((id) => GenreChip(genreId: id))
                              .toList(),
                        ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Meta row
                      Row(
                        children: [
                          if (movie.year > 0)
                            Text(
                              '${movie.year}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.accentPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (movie.isHiddenGem) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.gemsBadgeGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '💎 GEM',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Tap hint
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to view trailer',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppTheme.textMuted,
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
          // Skip button
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppTheme.accentSecondary,
                size: 28,
              ),
            ),
          ),

          // Center — undo
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
              child: const Icon(
                Icons.undo_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
          ),

          // Watch / Save button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.swipe(CardSwiperDirection.right);
            },
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary,
                shape: BoxShape.circle,
                boxShadow: AppTheme.amberGlow,
              ),
              child: const Icon(
                Icons.bookmark_add_rounded,
                color: AppTheme.textInverse,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
