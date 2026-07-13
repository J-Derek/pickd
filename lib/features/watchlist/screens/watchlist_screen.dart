import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/movie_model.dart';
import '../../watchlist/providers/watchlist_provider.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watchlist',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${watchlist.length} movie${watchlist.length == 1 ? '' : 's'} saved',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (watchlist.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.bgSurface,
                            title: const Text('Clear Watchlist', style: TextStyle(color: AppTheme.textPrimary)),
                            content: const Text('Are you sure you want to clear your watchlist?', style: TextStyle(color: AppTheme.textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Clear', style: TextStyle(color: AppTheme.accentPrimary)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          if (!context.mounted) return;
                          ref.read(watchlistProvider.notifier).clear();
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        backgroundColor: AppTheme.bgElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppTheme.bgMuted),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Clear All'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (watchlist.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentPrimary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentPrimary.withValues(alpha: 0.1),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.movie_filter_rounded,
                              size: 48,
                              color: AppTheme.accentPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Your Watchlist is Empty',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Swipe right on movies or shows to add them to your collection.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: () => context.go('/swipe'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPrimary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: AppTheme.cyanGlow,
                            ),
                            child: const Text(
                              'Start Swiping',
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
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: watchlist.length,
                  itemBuilder: (context, index) {
                    return _WatchlistCard(
                      movie: watchlist[index],
                      onRemove: () => ref
                          .read(watchlistProvider.notifier)
                          .remove(watchlist[index].id),
                      onTap: () => context.push(
                        '/movie/${watchlist[index].id}',
                        extra: watchlist[index],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: watchlist.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                if (watchlist.isEmpty) return;
                final randomMovie = (watchlist.toList()..shuffle()).first;
                context.push('/movie/${randomMovie.id}', extra: randomMovie);
              },
              backgroundColor: AppTheme.accentPrimary,
              icon: const Icon(Icons.casino_rounded, color: AppTheme.textInverse),
              label: const Text(
                'Surprise Me',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textInverse,
                ),
              ),
            )
          : null,
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _WatchlistCard({
    required this.movie,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.bgElevated,
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster
              movie.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.bgSurface,
                      child: const Icon(Icons.movie, color: AppTheme.textMuted),
                    ),
              // Gradient
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5, 1.0],
                      colors: [Colors.transparent, Color(0xEA0A0A0F)],
                    ),
                  ),
                ),
              ),
              // Remove button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Title
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
