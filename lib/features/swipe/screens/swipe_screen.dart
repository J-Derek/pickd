import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'dart:ui';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/discovery_service.dart';
import '../../../core/widgets/genre_chip.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/services/hive_service.dart';
import '../providers/swipe_provider.dart';
import 'auth_gate_sheet.dart';
import 'walkthrough_overlay.dart';
import '../../onboarding/providers/onboarding_provider.dart';


class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  bool _gateShown = false;
  bool _showWalkthrough = false;
  MediaFilter _activeFilter = MediaFilter.moviesOnly;

  @override
  void initState() {
    super.initState();
    _showWalkthrough = !HiveService.getProfile().hasSeenWalkthrough;
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
    
    final profile = HiveService.getProfile();
    if (profile.suppressAuthGate) {
      ref.read(swipeDeckProvider.notifier).resetSwipeGate();
      return;
    }

    _gateShown = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => const AuthGateSheet(),
    ).then((_) {
      if (!mounted) return;
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildFilterToggle(),
                Expanded(child: _buildBody(deckState)),
              ],
            ),
          ),
          if (_showWalkthrough)
            WalkthroughOverlay(
              onDismiss: () {
                setState(() => _showWalkthrough = false);
                final profile = HiveService.getProfile();
                profile.hasSeenWalkthrough = true;
                profile.save();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          const Text(
            'pickd',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentPrimary,
            ),
          ),
          const Spacer(),
          // Change Vibe
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Reset Hive profile so old tastes are completely wiped
              final profile = HiveService.getProfile();
              profile.selectedMoodIds = [];
              profile.tasteSeedMovieIds = [];
              profile.tasteSeedTvIds = [];
              profile.onboardingComplete = false;
              HiveService.saveProfile(profile);

              // Reset onboarding state so they can start fresh
              ref.invalidate(onboardingProvider);
              context.push('/onboarding/mood');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Change Vibe',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
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

  Widget _buildFilterToggle() {
    String currentLabel = 'MOVIES';
    switch (_activeFilter) {
      case MediaFilter.moviesOnly:
        currentLabel = 'MOVIES';
      case MediaFilter.both:
        currentLabel = 'BOTH';
      case MediaFilter.tvOnly:
        currentLabel = 'TV SHOWS';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: PopupMenuButton<MediaFilter>(
        offset: const Offset(0, 48),
        color: AppTheme.bgElevated,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        onSelected: _onFilterTap,
        itemBuilder: (context) => [
          _buildPopupMenuItem(MediaFilter.moviesOnly, 'MOVIES'),
          _buildPopupMenuItem(MediaFilter.tvOnly, 'TV SHOWS'),
          _buildPopupMenuItem(MediaFilter.both, 'BOTH'),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.textMuted, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MEDIA: $currentLabel',
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.textPrimary),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<MediaFilter> _buildPopupMenuItem(MediaFilter filter, String label) {
    final isSelected = _activeFilter == filter;
    return PopupMenuItem(
      value: filter,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Syne',
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildBody(SwipeDeckState deckState) {
    if (deckState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 28,
                  color: AppTheme.accentPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'That\'s a Wrap!',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You\'ve seen everything for this vibe. Try a different mood or load more.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(swipeDeckProvider.notifier).loadDeck();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Load More',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textInverse,
                  ),
                ),
              ),
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
            allowedSwipeDirection: const AllowedSwipeDirection.all(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            scale: 0.92,
            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
              if (index >= deck.length) return const SizedBox.shrink();
              return _SwipeCard(
                movie: deck[index],
                percentX: percentThresholdX.toDouble(),
                percentY: percentThresholdY.toDouble(), // Added Y
                onTap: () => context.push('/movie/${deck[index].id}',
                    extra: deck[index]),
              );
            },
            onSwipe: (prev, curr, dir) {
              final item = deck[prev];
              
              SwipeAction action;
              if (dir == CardSwiperDirection.right) {
                action = SwipeAction.save;
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved to Watchlist', style: TextStyle(color: AppTheme.textInverse, fontWeight: FontWeight.w600)),
                    backgroundColor: AppTheme.accentPrimary,
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 120, left: 24, right: 24),
                  ),
                );
              } else if (dir == CardSwiperDirection.top) {
                action = SwipeAction.watched;
                HapticFeedback.mediumImpact();
                ref.read(swipeDeckProvider.notifier).onSwiped(item, action);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marked as Watched', style: TextStyle(color: AppTheme.textInverse, fontWeight: FontWeight.w600)),
                    backgroundColor: AppTheme.accentGreen,
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 120, left: 24, right: 24),
                  ),
                );
                return true;
              } else if (dir == CardSwiperDirection.bottom) {
                action = SwipeAction.heart;
                HapticFeedback.mediumImpact();
              } else {
                action = SwipeAction.skip;
                HapticFeedback.lightImpact();
              }
              
              ref.read(swipeDeckProvider.notifier).onSwiped(item, action);
              return true;
            },
            onUndo: (prev, curr, dir) {
              if (prev == null) return false;
              final item = deck[prev];
              
              SwipeAction previousAction;
              if (dir == CardSwiperDirection.right) {
                previousAction = SwipeAction.save;
              } else if (dir == CardSwiperDirection.top) {
                previousAction = SwipeAction.watched;
              } else if (dir == CardSwiperDirection.bottom) {
                previousAction = SwipeAction.heart;
              } else {
                previousAction = SwipeAction.skip;
              }
              
              ref.read(swipeDeckProvider.notifier).onUndo(item, previousAction);
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
  final double percentY;
  final VoidCallback onTap;

  const _SwipeCard({
    required this.movie,
    required this.percentX,
    required this.percentY,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final watchIndicatorOpacity = (percentX.abs() / 100).clamp(0.0, 1.0);
    final topBottomOpacity = (percentY.abs() / 100).clamp(0.0, 1.0);

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
                    gradient: AppTheme.cardBottomGradient,
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
                      color: Colors.black.withValues(alpha: 0.8),
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
                        letterSpacing: 1.0,
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
                
              // WATCHED indicator (top swipe)
              if (percentY < 0)
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: topBottomOpacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.accentGreen,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'WATCHED IT',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentGreen,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // LIKE indicator (bottom swipe)
              if (percentY > 0)
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: topBottomOpacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'LOVE IT',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.pinkAccent,
                            letterSpacing: 2,
                          ),
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
                                'GEM',
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
                      const Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tap to view trailer',
                            style: TextStyle(
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

          // Heart / Like (Small, Bottom Swipe)
          _LabeledGlassButton(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.swipe(CardSwiperDirection.bottom);
            },
            size: 52,
            icon: Icons.favorite_rounded,
            iconColor: Colors.pinkAccent,
            label: 'LIKE',
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

          // Eye / Watched (Small, Top Swipe)
          _LabeledGlassButton(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.swipe(CardSwiperDirection.top);
            },
            size: 52,
            icon: Icons.visibility_rounded,
            iconColor: AppTheme.accentGreen,
            label: 'WATCHED',
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
