import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../providers/watchlist_provider.dart';
import '../providers/watched_vault_provider.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'My Collection',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.bgElevated,
                      width: 2,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.accentPrimary,
                  indicatorWeight: 3,
                  labelColor: AppTheme.accentPrimary,
                  unselectedLabelColor: AppTheme.textMuted,
                  labelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'To Watch'),
                    Tab(text: 'Watched'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ToWatchTab(onSwitchToWatched: () => _tabController.animateTo(1)),
                  const _WatchedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToWatchTab extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToWatched;
  
  const _ToWatchTab({required this.onSwitchToWatched});

  @override
  ConsumerState<_ToWatchTab> createState() => _ToWatchTabState();
}

class _ToWatchTabState extends ConsumerState<_ToWatchTab> {
  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    final watchlist = ref.watch(watchlistProvider);

    if (watchlist.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '0 items.',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                height: 1.0,
                letterSpacing: -1.5,
              ),
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
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.go('/swipe'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppTheme.accentPrimary,
                  borderRadius: BorderRadius.zero,
                ),
                child: const Text(
                  'Discover titles',
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${watchlist.length} saved',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => setState(() => _isGrid = !_isGrid),
                  ),
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
                        ref.read(watchlistProvider.notifier).clear();
                      }
                    },
                    child: const Text('Clear All', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isGrid
              ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: watchlist.length,
                  itemBuilder: (context, index) {
                    final movie = watchlist[index];
                    return _GridItemCard(
                      item: movie,
                      actionIcon: Icons.visibility_outlined,
                      actionColor: AppTheme.accentGreen,
                      onActionTap: () async {
                        await ref.read(watchedVaultProvider.notifier).addMedia(movie);
                        await ref.read(watchlistProvider.notifier).remove(movie.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content: const Text('Moved to Watched', style: TextStyle(color: AppTheme.textInverse)),
                                backgroundColor: AppTheme.accentGreen,
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'View',
                                  textColor: AppTheme.textInverse,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    widget.onSwitchToWatched();
                                  },
                                ),
                              ),
                            );
                        }
                      },
                      onRemove: () => ref.read(watchlistProvider.notifier).remove(movie.id),
                      onTap: () => context.push('/movie/${movie.id}', extra: movie),
                    );
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: watchlist.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final movie = watchlist[index];
                    return _ListItemCard(
                      item: movie,
                      actionIcon: Icons.visibility_outlined,
                      actionColor: AppTheme.accentGreen,
                      onActionTap: () async {
                        await ref.read(watchedVaultProvider.notifier).addMedia(movie);
                        await ref.read(watchlistProvider.notifier).remove(movie.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content: const Text('Moved to Watched', style: TextStyle(color: AppTheme.textInverse)),
                                backgroundColor: AppTheme.accentGreen,
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'View',
                                  textColor: AppTheme.textInverse,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    widget.onSwitchToWatched();
                                  },
                                ),
                              ),
                            );
                        }
                      },
                      onRemove: () => ref.read(watchlistProvider.notifier).remove(movie.id),
                      onTap: () => context.push('/movie/${movie.id}', extra: movie),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WatchedTab extends ConsumerStatefulWidget {
  const _WatchedTab();

  @override
  ConsumerState<_WatchedTab> createState() => _WatchedTabState();
}

class _WatchedTabState extends ConsumerState<_WatchedTab> {
  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    final watchedList = ref.watch(watchedVaultProvider);

    if (watchedList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '0 watched.',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                height: 1.0,
                letterSpacing: -1.5,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Movies and shows you mark as watched will appear here.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${watchedList.length} watched',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => setState(() => _isGrid = !_isGrid),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.bgSurface,
                          title: const Text('Clear History', style: TextStyle(color: AppTheme.textPrimary)),
                          content: const Text('Are you sure you want to clear your watched history?', style: TextStyle(color: AppTheme.textSecondary)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Clear', style: TextStyle(color: AppTheme.accentSecondary)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(watchedVaultProvider.notifier).clear();
                      }
                    },
                    child: const Text('Clear All', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isGrid
              ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: watchedList.length,
                  itemBuilder: (context, index) {
                    final movie = watchedList[index];
                    return _GridItemCard(
                      item: movie,
                      actionIcon: Icons.bookmark_add_outlined,
                      actionColor: AppTheme.accentPrimary,
                      onActionTap: () async {
                        await ref.read(watchlistProvider.notifier).addMedia(movie);
                        await ref.read(watchedVaultProvider.notifier).remove(movie.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Moved back to Watchlist', style: TextStyle(color: AppTheme.textInverse)),
                                backgroundColor: AppTheme.accentPrimary,
                                duration: Duration(seconds: 3),
                              ),
                            );
                        }
                      },
                      onRemove: () => ref.read(watchedVaultProvider.notifier).remove(movie.id),
                      onTap: () => context.push('/movie/${movie.id}', extra: movie),
                    );
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: watchedList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final movie = watchedList[index];
                    return _ListItemCard(
                      item: movie,
                      actionIcon: Icons.bookmark_add_outlined,
                      actionColor: AppTheme.accentPrimary,
                      onActionTap: () async {
                        await ref.read(watchlistProvider.notifier).addMedia(movie);
                        await ref.read(watchedVaultProvider.notifier).remove(movie.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Moved back to Watchlist', style: TextStyle(color: AppTheme.textInverse)),
                                backgroundColor: AppTheme.accentPrimary,
                                duration: Duration(seconds: 3),
                              ),
                            );
                        }
                      },
                      onRemove: () => ref.read(watchedVaultProvider.notifier).remove(movie.id),
                      onTap: () => context.push('/movie/${movie.id}', extra: movie),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _GridItemCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onActionTap;
  final IconData actionIcon;
  final Color actionColor;

  const _GridItemCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
    required this.onActionTap,
    required this.actionIcon,
    required this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            item.posterPath != null
                ? CachedNetworkImage(
                    imageUrl: item.posterUrl,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppTheme.bgSurface,
                    child: const Icon(Icons.movie, color: AppTheme.textMuted),
                  ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onActionTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgPrimary.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(actionIcon, size: 16, color: actionColor),
                ),
              ),
            ),
            Positioned(
              top: 6,
              left: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgPrimary.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListItemCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onActionTap;
  final IconData actionIcon;
  final Color actionColor;

  const _ListItemCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
    required this.onActionTap,
    required this.actionIcon,
    required this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bgMuted.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: SizedBox(
                width: 80,
                height: double.infinity,
                child: item.posterPath != null
                    ? CachedNetworkImage(
                        imageUrl: item.posterUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppTheme.bgSurface,
                        child: const Icon(Icons.movie, color: AppTheme.textMuted),
                      ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isTv) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'TV',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.year > 0)
                          Text(
                            '${item.year}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        const SizedBox(width: 12),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          item.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: onActionTap,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: actionColor.withValues(alpha: 0.3)),
                            ),
                            child: Icon(actionIcon, size: 18, color: actionColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.bgMuted),
                            ),
                            child: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
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
