import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/discovery_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/genre_chip.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/providers/user_profile_details_provider.dart';
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
  MediaFilter _activeFilter = MediaFilter.both;

  final GlobalKey _vibeKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _likeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _showWalkthrough = !HiveService.getProfile().hasSeenWalkthrough;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(swipeDeckProvider.notifier).loadDeck();
      if (_showWalkthrough) {
        ShowCaseWidget.of(context).startShowCase([_vibeKey, _cardKey, _likeKey]);
        final profile = HiveService.getProfile();
        profile.hasSeenWalkthrough = true;
        profile.save();
      }
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
                _buildFilterToggle(deckState.filter),
                Expanded(child: _buildBody(deckState)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17) {
      greeting = 'Good evening';
    }

    final user = ref.watch(currentUserProvider);
    final profileDetails = ref.watch(userProfileDetailsProvider).valueOrNull;
    final displayName = profileDetails?.displayName;
    final avatarUrl = profileDetails?.avatarUrl;
    final isGuest = user == null || user.isAnonymous;
    
    String resolvedName = '';
    if (displayName != null && displayName.isNotEmpty) {
      resolvedName = displayName;
    } else if (!isGuest && user.email != null) {
      final prefix = user.email!.split('@').first;
      resolvedName = prefix.length > 12 ? prefix.substring(0, 12) : prefix;
    }
    
    final greetingText = resolvedName.isNotEmpty ? '$greeting, $resolvedName 👋' : '$greeting 👋';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          // Avatar
          avatarUrl != null && avatarUrl.isNotEmpty
            ? CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.bgMuted,
                backgroundImage: NetworkImage(avatarUrl),
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bgMuted,
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
          const SizedBox(width: 12),
          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'Ready to find a movie?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Change Vibe
          Showcase(
            key: _vibeKey,
            title: 'Change Your Vibe',
            description: 'Tap here anytime to switch up your mood and get new recommendations!',
            tooltipBackgroundColor: AppTheme.bgElevated,
            textColor: Colors.white,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Reset onboarding state so they can start fresh,
                // but preserve Hive profile until they complete onboarding
                ref.invalidate(onboardingProvider);
                context.push('/onboarding/mood');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.bgElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(MediaFilter activeFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.bgMuted),
        ),
        child: IntrinsicWidth(
          child: Row(
            children: [
              _FilterPill('Movies', activeFilter == MediaFilter.moviesOnly,
                  () => _onFilterTap(MediaFilter.moviesOnly)),
              _FilterPill('Both', activeFilter == MediaFilter.both,
                  () => _onFilterTap(MediaFilter.both)),
              _FilterPill('TV Shows', activeFilter == MediaFilter.tvOnly,
                  () => _onFilterTap(MediaFilter.tvOnly)),
            ],
          ),
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
                  LucideIcons.film,
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
            Material(
              color: AppTheme.accentPrimary,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(swipeDeckProvider.notifier).loadMore();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
          child: Showcase(
            key: _cardKey,
            title: 'Swipe to Decide',
            description: 'Swipe RIGHT to save to Watchlist, LEFT to pass, and UP to mark as watched. Tap the card for details!',
            tooltipBackgroundColor: AppTheme.accentPrimary,
            textColor: Colors.white,
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
                showCustomSnackBar(
                  context,
                  message: 'Saved to Watchlist',
                  isSuccess: true,
                  duration: const Duration(seconds: 1),
                );
              } else if (dir == CardSwiperDirection.top) {
                action = SwipeAction.watched;
                HapticFeedback.mediumImpact();
                ref.read(swipeDeckProvider.notifier).onSwiped(item, action);
                showCustomSnackBar(
                  context,
                  message: 'Marked as Watched',
                  isSuccess: true,
                  duration: const Duration(seconds: 1),
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
        )),
        // Action buttons
        _ActionButtons(controller: _swiperController, likeKey: _likeKey),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterPill(this.label, this.isActive, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppTheme.textInverse : AppTheme.textSecondary,
          ),
        ),
      ),
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
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
                            color: AppTheme.gemsColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gemsColor,
                            ),
                          ),
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
  final GlobalKey likeKey;

  const _ActionButtons({required this.controller, required this.likeKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Undo (Small)
          _SmallActionButton(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.undo();
            },
            icon: Icons.undo_rounded,
          ),
          
          // Skip / X (Large)
          _LargeActionButton(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.swipe(CardSwiperDirection.left);
            },
            icon: Icons.close_rounded,
            iconColor: AppTheme.textSecondary,
            backgroundColor: AppTheme.bgElevated,
          ),

          // Like (Large Glowing)
          Showcase(
            key: likeKey,
            title: 'Love it!',
            description: 'Too tired to swipe? Just tap the buttons down here.',
            tooltipBackgroundColor: AppTheme.errorColor, // Neon Pink
            textColor: Colors.white,
            child: _LargeActionButton(
              onTap: () {
                HapticFeedback.mediumImpact();
                controller.swipe(CardSwiperDirection.right);
              },
              icon: Icons.favorite_rounded,
              iconColor: Colors.white,
              backgroundColor: AppTheme.errorColor, // Neon Pink
              isGlowing: true,
            ),
          ),

          // Watched (Small)
          _SmallActionButton(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.swipe(CardSwiperDirection.top);
            },
            icon: Icons.visibility_rounded,
          ),
        ],
      ),
    );
  }
}

class _LargeActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isGlowing;

  const _LargeActionButton({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.isGlowing = false,
  });

  @override
  State<_LargeActionButton> createState() => _LargeActionButtonState();
}

class _LargeActionButtonState extends State<_LargeActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double size = 72.0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.backgroundColor,
            boxShadow: widget.isGlowing
                ? [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 4,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _SmallActionButton({
    required this.onTap,
    required this.icon,
  });

  @override
  State<_SmallActionButton> createState() => _SmallActionButtonState();
}

class _SmallActionButtonState extends State<_SmallActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double size = 52.0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.bgElevated,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: AppTheme.textMuted,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}
