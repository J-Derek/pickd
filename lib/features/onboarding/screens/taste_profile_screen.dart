import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/config/mood_config.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/tmdb_service.dart';
import '../../../core/services/supabase_db_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../swipe/providers/swipe_provider.dart';
import '../providers/onboarding_provider.dart';

class TasteProfileScreen extends ConsumerStatefulWidget {
  final bool isEditing;

  const TasteProfileScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<TasteProfileScreen> createState() => _TasteProfileScreenState();
}

class _TasteProfileScreenState extends ConsumerState<TasteProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<MediaItem> _gridItems = [];
  final Set<int> _watchedIds = {};
  int _currentPage = 1;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;
  bool _isGrid = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _fetchWatchedIds();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchWatchedIds() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getWatchlist(user.id);
      final watched = list.where((e) => e['is_watched'] == true).map((e) => e['media_id'] as int).toSet();
      if (mounted) {
        setState(() {
          _watchedIds.addAll(watched);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _isSearching = false;
          _gridItems.clear();
          _currentPage = 1;
        });
        _loadMore();
      } else {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _isSearching = true;
      _gridItems.clear();
    });
    try {
      final results = await TmdbService.searchMulti(query);
      if (mounted) {
        setState(() {
          _gridItems.addAll(results);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_isSearching) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    
    final state = ref.read(onboardingProvider);
    final moodIds = state.selectedMoodIds;
    List<MediaItem> newItems = [];
    
    if (moodIds.isNotEmpty) {
      final genreIds = <int>{};
      for (final id in moodIds) {
        final parsed = int.tryParse(id);
        if (parsed != null) {
          genreIds.add(parsed);
        } else {
          final selectedMoods = kMoods.where((m) => m.id == id);
          genreIds.addAll(selectedMoods.expand((m) => m.genreIds));
        }
      }
      
      if (genreIds.isNotEmpty) {
        final movies = await TmdbService.discoverMovies(genreIds: genreIds.toList(), page: _currentPage);
        final tv = await TmdbService.discoverTv(genreIds: genreIds.toList(), page: _currentPage);
        newItems.addAll(movies.map((m) => MediaItem.movie(m)));
        newItems.addAll(tv.map((t) => MediaItem.tv(t)));
        newItems.shuffle();
      }
    }
    
    // Fallback if empty
    if (newItems.isEmpty) {
      final results = await TmdbService.getPopularMoviesForOnboarding(_currentPage);
      newItems = results.map((m) => MediaItem.movie(m)).toList();
    }
    
    if (!mounted) return;
    
    setState(() {
      _gridItems.addAll(newItems);
      _currentPage++;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/onboarding/mood');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text('Back', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
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
                              await notifier.completeOnboarding();
                              if (widget.isEditing) {
                                ref.read(swipeDeckProvider.notifier).resetSwipeGate();
                                ref.read(swipeDeckProvider.notifier).loadDeck();
                                if (context.mounted) {
                                  context.pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Taste Seeds updated', style: TextStyle(color: AppTheme.textInverse)),
                                      backgroundColor: AppTheme.accentPrimary,
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) context.go('/swipe');
                              }
                            },
                            child: const Text('Done', style: TextStyle(color: AppTheme.accentPrimary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pick 3 you love',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the posters of movies you already enjoy. We\'ll build your custom algorithm from these.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search movies & TV...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgSurface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppTheme.bgElevated),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppTheme.bgElevated),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppTheme.accentPrimary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Selected Media Pills
                  if (state.tasteMedia.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.tasteMedia.map((media) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.bgElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    media.title,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => notifier.removeTasteMedia(media.id),
                                  child: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            
            Expanded(
              child: _isGrid
                  ? GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _gridItems.length + (_isLoading ? 3 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _gridItems.length) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }

                        final movie = _gridItems[index];
                        final isSelected = state.tasteMedia.any((m) => m.id == movie.id);
                        final isWatched = _watchedIds.contains(movie.id);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isWatched ? null : () {
                              if (isSelected) {
                                notifier.removeTasteMedia(movie.id);
                              } else {
                                notifier.addTasteMedia(movie);
                                if (state.tasteMedia.length == 2) { // 2 because it updates next frame to 3
                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Nice pick! Add more to fine-tune your recommendations.',
                                          style: TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
                                        ),
                                        duration: Duration(seconds: 4),
                                        backgroundColor: AppTheme.bgElevated,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                }
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              transform: Matrix4.diagonal3Values(
                                isSelected ? 0.95 : 1.0,
                                isSelected ? 0.95 : 1.0,
                                1.0,
                              ),
                              transformAlignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.zero,
                                border: Border.all(
                                  color: isSelected ? AppTheme.accentPrimary : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.zero,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Opacity(
                                    opacity: isWatched ? 0.3 : 1.0,
                                    child: movie.posterPath != null
                                        ? CachedNetworkImage(
                                            imageUrl: movie.posterUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(color: AppTheme.bgSurface),
                                            errorWidget: (context, url, error) =>
                                                Container(color: AppTheme.bgSurface),
                                          )
                                        : Container(color: AppTheme.bgSurface),
                                  ),
                                  if (isSelected)
                                    Container(
                                      color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: AppTheme.textInverse,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  if (isWatched)
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      child: const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.visibility_rounded,
                                              color: AppTheme.accentGreen,
                                              size: 32,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Watched',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.accentGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        );
                      },
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _gridItems.length + (_isLoading ? 3 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index >= _gridItems.length) {
                          return Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }

                        final movie = _gridItems[index];
                        final isSelected = state.tasteMedia.any((m) => m.id == movie.id);
                        final isWatched = _watchedIds.contains(movie.id);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isWatched ? null : () {
                              if (isSelected) {
                                notifier.removeTasteMedia(movie.id);
                              } else {
                                notifier.addTasteMedia(movie);
                                if (state.tasteMedia.length == 2) {
                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Nice pick! Add more to fine-tune your recommendations.',
                                          style: TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
                                        ),
                                        duration: Duration(seconds: 4),
                                        backgroundColor: AppTheme.bgElevated,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                }
                              }
                            },
                            child: Opacity(
                              opacity: isWatched ? 0.5 : 1.0,
                              child: Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.accentPrimary.withValues(alpha: 0.1) : AppTheme.bgSurface,
                                  borderRadius: BorderRadius.zero,
                                  border: Border.all(
                                    color: isSelected ? AppTheme.accentPrimary : AppTheme.bgMuted,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.zero,
                                    child: movie.posterPath != null
                                        ? CachedNetworkImage(
                                            imageUrl: movie.posterUrl,
                                            width: 60,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(width: 60, color: AppTheme.bgMuted),
                                            errorWidget: (_, __, ___) => Container(width: 60, color: AppTheme.bgMuted),
                                          )
                                        : Container(width: 60, color: AppTheme.bgMuted),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          movie.title,
                                          style: const TextStyle(
                                            fontFamily: 'Syne',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          movie.year.toString(),
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        if (isWatched) ...[
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Watched',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.accentGreen,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 16),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: AppTheme.accentPrimary,
                                        size: 24,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        );
                      },
                    ),
            ),

            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${state.tasteMedia.length}/3 selected',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: state.canProceedFromTaste ? AppTheme.accentGreen : AppTheme.textMuted,
                        ),
                      ),
                      const Spacer(),
                      if (state.canProceedFromTaste)
                        const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedOpacity(
                    opacity: state.canProceedFromTaste ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: state.canProceedFromTaste
                          ? () async {
                              await notifier.completeOnboarding();
                              if (context.mounted) {
                                ref.read(swipeDeckProvider.notifier).loadDeck();
                                context.go('/swipe');
                              }
                            }
                          : null,
                      child: Text(
                        state.canProceedFromTaste
                            ? 'Start Swiping'
                            : 'Pick ${3 - state.tasteMedia.length} more movies',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
