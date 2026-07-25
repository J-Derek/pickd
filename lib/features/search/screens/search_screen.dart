import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/tmdb_service.dart';
import '../../../core/widgets/clearable_text_field.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<String> _recentSearches = [];
  List<MediaItem> _trendingItems = [];
  List<MediaItem> _searchResults = [];
  
  bool _isLoadingTrending = false;
  bool _isLoadingSearch = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadTrending();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = HiveService.getRecentSearches();
    });
  }

  Future<void> _loadTrending() async {
    setState(() {
      _isLoadingTrending = true;
    });
    final items = await TmdbService.getTrendingMulti();
    if (mounted) {
      setState(() {
        _trendingItems = items.take(5).toList();
        _isLoadingTrending = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoadingSearch = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoadingSearch = true;
    });
    final results = await TmdbService.searchMulti(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoadingSearch = false;
      });
    }
  }

  Future<void> _onSearchSubmitted(String query) async {
    final q = query.trim();
    if (q.isNotEmpty) {
      await HiveService.addRecentSearch(q);
      _loadRecentSearches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header & Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClearableTextField(
                controller: _searchController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearchSubmitted,
                hintText: 'Movies, shows, directors...',
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: hasQuery
                  ? _buildSearchResults()
                  : _buildHomeState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Section
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await HiveService.clearRecentSearches();
                      _loadRecentSearches();
                      HapticFeedback.lightImpact();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final query = _recentSearches[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        _searchController.text = query;
                        _focusNode.unfocus();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.bgMuted),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.history,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              query,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Trending Section
          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'TRENDING',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingTrending)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppTheme.accentPrimary),
              ),
            )
          else if (_trendingItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Text(
                'No trending items available.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trendingItems.length,
              itemBuilder: (context, index) {
                final item = _trendingItems[index];
                final rank = index + 1;
                return _TrendingTile(
                  rank: rank,
                  item: item,
                  onTap: () {
                    _onSearchSubmitted(item.title);
                    context.push('/movie/${item.id}', extra: item);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoadingSearch) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No results found.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: AppTheme.textMuted,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              _onSearchSubmitted(item.title);
              context.push('/movie/${item.id}', extra: item);
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.posterUrl,
                    width: 46,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 46,
                      height: 68,
                      color: AppTheme.bgSurface,
                      child: const Icon(
                        Icons.movie,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.isTv ? "TV Series" : "Movie"} • ${item.year}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrendingTile extends StatelessWidget {
  final int rank;
  final MediaItem item;
  final VoidCallback onTap;

  const _TrendingTile({
    required this.rank,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // Rank Number
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? AppTheme.accentPrimary : AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Fire Icon
            const Icon(
              LucideIcons.flame,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
