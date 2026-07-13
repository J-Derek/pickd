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
import '../../../core/services/hive_service.dart';
import '../../swipe/providers/swipe_provider.dart';
import '../providers/onboarding_provider.dart';

class TasteProfileScreen extends ConsumerStatefulWidget {
  const TasteProfileScreen({super.key});

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
      // Import kMoods to get genres
      final selectedMoods = kMoods.where((m) => moodIds.contains(m.id));
      final genreIds = selectedMoods.expand((m) => m.genreIds).toSet().toList();
      
      if (genreIds.isNotEmpty) {
        final movies = await TmdbService.discoverMovies(genreIds: genreIds, page: _currentPage);
        final tv = await TmdbService.discoverTv(genreIds: genreIds, page: _currentPage);
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
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/onboarding/mood');
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text('Back', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await notifier.completeOnboarding();
                          if (context.mounted) context.go('/swipe');
                        },
                        child: const Text('Skip', style: TextStyle(color: AppTheme.textMuted)),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.bgElevated),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.bgElevated),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.accentPrimary, width: 1.5),
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
            
            // Grid
            Expanded(
              child: GridView.builder(
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

                  return GestureDetector(
                    onTap: isWatched ? null : () {
                      if (isSelected) {
                        notifier.removeTasteMedia(movie.id);
                      } else {
                        notifier.addTasteMedia(movie);
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.accentPrimary : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected ? AppTheme.cyanGlow : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
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
                            ? 'Start Swiping 🎬'
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
