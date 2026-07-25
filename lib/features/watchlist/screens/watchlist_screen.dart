import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../providers/watchlist_provider.dart';
import '../providers/watched_vault_provider.dart';

// ─── Filter Enums & Helpers ───────────────────────────────────────────────────

enum _SortOrder { newest, oldest, az }

enum _TypeFilter { all, movies, tv }

List<MediaItem> _applyFilters(
  List<MediaItem> list, {
  required String searchQuery,
  required _TypeFilter typeFilter,
  required _SortOrder sortOrder,
}) {
  var result = list.where((item) {
    final matchesSearch =
        item.title.toLowerCase().contains(searchQuery.toLowerCase());
    final matchesType = switch (typeFilter) {
      _TypeFilter.all => true,
      _TypeFilter.movies => item.isMovie,
      _TypeFilter.tv => item.isTv,
    };
    return matchesSearch && matchesType;
  }).toList();
  switch (sortOrder) {
    case _SortOrder.oldest:
      return result.reversed.toList();
    case _SortOrder.az:
      result.sort((a, b) => a.title.compareTo(b.title));
      return result;
    case _SortOrder.newest:
      return result;
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

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
                    bottom: BorderSide(color: AppTheme.bgElevated, width: 2),
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
                      fontSize: 15),
                  unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 15),
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
                  _ToWatchTab(
                      onSwitchToWatched: () => _tabController.animateTo(1)),
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

// ─── To Watch Tab ─────────────────────────────────────────────────────────────

class _ToWatchTab extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToWatched;
  const _ToWatchTab({required this.onSwitchToWatched});

  @override
  ConsumerState<_ToWatchTab> createState() => _ToWatchTabState();
}

class _ToWatchTabState extends ConsumerState<_ToWatchTab> {
  bool _isGrid = true;
  String _searchQuery = '';
  _TypeFilter _typeFilter = _TypeFilter.all;
  _SortOrder _sortOrder = _SortOrder.newest;

  @override
  Widget build(BuildContext context) {
    final watchlist = ref.watch(watchlistProvider);
    final isLoading = ref.watch(isWatchlistLoadingProvider);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentPrimary,
        ),
      );
    }

    if (watchlist.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('0 items.',
                style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.0,
                    letterSpacing: -1.5)),
            const SizedBox(height: 12),
            const Text(
                'Swipe right on movies or shows to add them to your collection.',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 32),
            Material(
              color: AppTheme.accentPrimary,
              child: InkWell(
                onTap: () => context.go('/swipe'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: const Text('Discover titles',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textInverse)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _applyFilters(watchlist,
        searchQuery: _searchQuery,
        typeFilter: _typeFilter,
        sortOrder: _sortOrder);

    return Column(
      children: [
        _WatchlistFilterBar(
          searchHint: 'Search your collection...',
          searchQuery: _searchQuery,
          typeFilter: _typeFilter,
          sortOrder: _sortOrder,
          onSearchChanged: (v) => setState(() => _searchQuery = v),
          onTypeChanged: (v) => setState(() => _typeFilter = v),
          onSortChanged: (v) => setState(() => _sortOrder = v),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${filtered.length} ${filtered.length == 1 ? "item" : "items"}',
                  style: Theme.of(context).textTheme.bodyMedium),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                        _isGrid
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        color: AppTheme.textSecondary),
                    onPressed: () => setState(() => _isGrid = !_isGrid),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.bgSurface,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          title: const Text('Clear Watchlist',
                              style:
                                  TextStyle(color: AppTheme.textPrimary)),
                          content: const Text('Are you sure?',
                              style:
                                  TextStyle(color: AppTheme.textSecondary)),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(false),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary))),
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(true),
                                child: const Text('Clear',
                                    style: TextStyle(
                                        color: AppTheme.accentSecondary))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(watchlistProvider.notifier).clear();
                      }
                    },
                    child: const Text('Clear All',
                        style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _NoResults(query: _searchQuery)
              : _isGrid
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16),
                      itemCount: filtered.length,
                      itemBuilder: (itemCtx, index) {
                        final movie = filtered[index];
                        return _GridItemCard(
                          item: movie,
                          actionIcon: Icons.visibility_outlined,
                          actionColor: AppTheme.accentGreen,
                          onActionTap: () async {
                            showCustomSnackBar(
                              context,
                              message: 'Moved to Watched',
                              isSuccess: true,
                            );
                            await ref
                                .read(watchedVaultProvider.notifier)
                                .addMedia(movie);
                            await ref
                                .read(watchlistProvider.notifier)
                                .remove(movie.mediaKey);
                          },
                          onRemove: () async {
                            showCustomSnackBar(
                              context,
                              message: 'Removed ${movie.title}',
                              isSuccess: true,
                            );
                            final notifier = ref.read(watchlistProvider.notifier);
                            await notifier.remove(movie.mediaKey);
                          },
                          onTap: () => context.push(
                              '/movie/${movie.id}',
                              extra: movie),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 16),
                      itemBuilder: (itemCtx, index) {
                        final movie = filtered[index];
                        return _ListItemCard(
                          item: movie,
                          actionIcon: Icons.visibility_outlined,
                          actionColor: AppTheme.accentGreen,
                          onActionTap: () async {
                            showCustomSnackBar(
                              context,
                              message: 'Moved to Watched',
                              isSuccess: true,
                            );
                            await ref
                                .read(watchedVaultProvider.notifier)
                                .addMedia(movie);
                            await ref
                                .read(watchlistProvider.notifier)
                                .remove(movie.mediaKey);
                          },
                          onRemove: () async {
                            showCustomSnackBar(
                              context,
                              message: 'Removed ${movie.title}',
                              isSuccess: true,
                            );
                            final notifier = ref.read(watchlistProvider.notifier);
                            await notifier.remove(movie.mediaKey);
                          },
                          onTap: () => context.push(
                              '/movie/${movie.id}',
                              extra: movie),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ─── Watched Tab ──────────────────────────────────────────────────────────────

class _WatchedTab extends ConsumerStatefulWidget {
  const _WatchedTab();

  @override
  ConsumerState<_WatchedTab> createState() => _WatchedTabState();
}

class _WatchedTabState extends ConsumerState<_WatchedTab> {
  bool _isGrid = true;
  String _searchQuery = '';
  _TypeFilter _typeFilter = _TypeFilter.all;
  _SortOrder _sortOrder = _SortOrder.newest;

  @override
  Widget build(BuildContext context) {
    final watchedList = ref.watch(watchedVaultProvider);
    final isLoading = ref.watch(isWatchedLoadingProvider);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentPrimary,
        ),
      );
    }

    if (watchedList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('0 watched.',
                style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.0,
                    letterSpacing: -1.5)),
            SizedBox(height: 12),
            Text(
                'Movies and shows you mark as watched will appear here.',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5)),
          ],
        ),
      );
    }

    final filtered = _applyFilters(watchedList,
        searchQuery: _searchQuery,
        typeFilter: _typeFilter,
        sortOrder: _sortOrder);

    return Column(
      children: [
        _WatchlistFilterBar(
          searchHint: 'Search watched history...',
          searchQuery: _searchQuery,
          typeFilter: _typeFilter,
          sortOrder: _sortOrder,
          onSearchChanged: (v) => setState(() => _searchQuery = v),
          onTypeChanged: (v) => setState(() => _typeFilter = v),
          onSortChanged: (v) => setState(() => _sortOrder = v),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${filtered.length} watched',
                  style: Theme.of(context).textTheme.bodyMedium),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                        _isGrid
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        color: AppTheme.textSecondary),
                    onPressed: () => setState(() => _isGrid = !_isGrid),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.bgSurface,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          title: const Text('Clear History',
                              style:
                                  TextStyle(color: AppTheme.textPrimary)),
                          content: const Text('Are you sure?',
                              style:
                                  TextStyle(color: AppTheme.textSecondary)),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(false),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary))),
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(true),
                                child: const Text('Clear',
                                    style: TextStyle(
                                        color: AppTheme.accentSecondary))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(watchedVaultProvider.notifier).clear();
                      }
                    },
                    child: const Text('Clear All',
                        style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _NoResults(query: _searchQuery)
              : _isGrid
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16),
                      itemCount: filtered.length,
                      itemBuilder: (itemCtx, index) {
                        final movie = filtered[index];
                        return _GridItemCard(
                          item: movie,
                          actionIcon: Icons.bookmark_add_outlined,
                          actionColor: AppTheme.accentPrimary,
                          onActionTap: () async {
                            showCustomSnackBar(
                              context,
                              message: 'Moved back to Watchlist',
                              isSuccess: true,
                            );
                            await ref
                                .read(watchlistProvider.notifier)
                                .addMedia(movie);
                            await ref
                                .read(watchedVaultProvider.notifier)
                                .remove(movie.mediaKey);
                          },
                          onRemove: () async {
                            showCustomSnackBar(
                              context,
                              message: 'Removed ${movie.title}',
                              isSuccess: true,
                            );
                            final notifier = ref.read(watchedVaultProvider.notifier);
                            await notifier.remove(movie.mediaKey);
                          },
                          onTap: () => context.push(
                              '/movie/${movie.id}',
                              extra: movie),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 16),
                      itemBuilder: (itemCtx, index) {
                        final movie = filtered[index];
                        return _ListItemCard(
                          item: movie,
                          actionIcon: Icons.bookmark_add_outlined,
                          actionColor: AppTheme.accentPrimary,
                          onActionTap: () async {
                            showCustomSnackBar(
                              context,
                              message: 'Moved back to Watchlist',
                              isSuccess: true,
                            );
                            await ref
                                .read(watchlistProvider.notifier)
                                .addMedia(movie);
                            await ref
                                .read(watchedVaultProvider.notifier)
                                .remove(movie.mediaKey);
                          },
                          onRemove: () async {
                            showCustomSnackBar(
                              context,
                              message: 'Removed ${movie.title}',
                              isSuccess: true,
                            );
                            final notifier = ref.read(watchedVaultProvider.notifier);
                            await notifier.remove(movie.mediaKey);
                          },
                          onTap: () => context.push(
                              '/movie/${movie.id}',
                              extra: movie),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ─── Filter Bar Widget ────────────────────────────────────────────────────────

class _WatchlistFilterBar extends StatelessWidget {
  final String searchHint;
  final String searchQuery;
  final _TypeFilter typeFilter;
  final _SortOrder sortOrder;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_TypeFilter> onTypeChanged;
  final ValueChanged<_SortOrder> onSortChanged;

  const _WatchlistFilterBar({
    required this.searchHint,
    required this.searchQuery,
    required this.typeFilter,
    required this.sortOrder,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(
                fontFamily: 'Inter',
                color: AppTheme.textPrimary,
                fontSize: 14),
            decoration: InputDecoration(
              hintText: searchHint,
              hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.textMuted,
                  fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.textMuted, size: 20),
              filled: true,
              fillColor: AppTheme.bgElevated,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _TypePill(
                  label: 'All',
                  value: _TypeFilter.all,
                  current: typeFilter,
                  onTap: onTypeChanged),
              const SizedBox(width: 8),
              _TypePill(
                  label: 'Movies',
                  value: _TypeFilter.movies,
                  current: typeFilter,
                  onTap: onTypeChanged),
              const SizedBox(width: 8),
              _TypePill(
                  label: 'TV',
                  value: _TypeFilter.tv,
                  current: typeFilter,
                  onTap: onTypeChanged),
              const Spacer(),
              _SortBtn(current: sortOrder, onChanged: onSortChanged),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final _TypeFilter value;
  final _TypeFilter current;
  final ValueChanged<_TypeFilter> onTap;

  const _TypePill(
      {required this.label,
      required this.value,
      required this.current,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentPrimary : AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive
                ? AppTheme.textInverse
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortBtn extends StatelessWidget {
  final _SortOrder current;
  final ValueChanged<_SortOrder> onChanged;

  const _SortBtn({required this.current, required this.onChanged});

  String get _label => switch (current) {
        _SortOrder.newest => 'Newest',
        _SortOrder.oldest => 'Oldest',
        _SortOrder.az => 'A → Z',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<_SortOrder>(
          context: context,
          backgroundColor: AppTheme.bgSurface,
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sort by',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                for (final order in _SortOrder.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      switch (order) {
                        _SortOrder.newest => 'Newest first',
                        _SortOrder.oldest => 'Oldest first',
                        _SortOrder.az => 'A → Z',
                      },
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: order == current
                            ? AppTheme.accentPrimary
                            : AppTheme.textPrimary,
                        fontWeight: order == current
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: order == current
                        ? const Icon(Icons.check,
                            color: AppTheme.accentPrimary)
                        : null,
                    onTap: () => Navigator.of(context).pop(order),
                  ),
              ],
            ),
          ),
        );
        if (result != null) onChanged(result);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: AppTheme.bgElevated,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded,
                size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(_label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              query.isNotEmpty
                  ? 'No results for "$query"'
                  : 'No items match this filter',
              style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text('Try a different search or filter.',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppTheme.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Grid Item Card ───────────────────────────────────────────────────────────

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
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
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
                    child:
                        const Icon(Icons.movie, color: AppTheme.textMuted),
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
                  child: const Icon(Icons.close,
                      size: 16, color: AppTheme.textMuted),
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

// ─── List Item Card ───────────────────────────────────────────────────────────

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
          border:
              Border.all(color: AppTheme.bgMuted.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(15)),
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
                        child: const Icon(Icons.movie,
                            color: AppTheme.textMuted),
                      ),
              ),
            ),
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
                                color: AppTheme.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isTv) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPrimary
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('TV',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentPrimary)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.year > 0)
                          Text('${item.year}',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppTheme.textSecondary)),
                        const SizedBox(width: 12),
                        const Icon(Icons.star,
                            color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(item.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 13,
                                color: AppTheme.textPrimary)),
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
                              border: Border.all(
                                  color: actionColor.withValues(alpha: 0.3)),
                            ),
                            child: Icon(actionIcon,
                                size: 18, color: actionColor),
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
                              border:
                                  Border.all(color: AppTheme.bgMuted),
                            ),
                            child: const Icon(Icons.close,
                                size: 18, color: AppTheme.textMuted),
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
