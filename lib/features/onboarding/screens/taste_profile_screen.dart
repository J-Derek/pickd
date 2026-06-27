import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/media_item.dart';
import '../../../core/services/tmdb_service.dart';
import '../providers/onboarding_provider.dart';

class TasteProfileScreen extends ConsumerStatefulWidget {
  const TasteProfileScreen({super.key});

  @override
  ConsumerState<TasteProfileScreen> createState() =>
      _TasteProfileScreenState();
}

class _TasteProfileScreenState extends ConsumerState<TasteProfileScreen> {
  final _searchController = TextEditingController();
  List<MediaItem> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await TmdbService.searchMulti(query);
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
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
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.go('/onboarding/mood'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Favorites you\nalready love',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add at least 3 movies or TV shows. We\'ll find matches with that same energy.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.bgMuted),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search movies & TV shows...',
                        hintStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: _search,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selected movies chips
            if (state.tasteMedia.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: state.tasteMedia.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final movie = state.tasteMedia[index];
                    return Chip(
                      label: Text(
                        movie.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: AppTheme.accentPrimary.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: AppTheme.accentPrimary.withValues(alpha: 0.4),
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      onDeleted: () => notifier.removeTasteMedia(movie.id),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // Search results
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : _searchResults.isNotEmpty
                      ? ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 1),
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            final isAdded = state.tasteMedia
                                .any((m) => m.id == movie.id);
                            return _MovieSearchTile(
                              movie: movie,
                              isAdded: isAdded,
                              onTap: () {
                                if (isAdded) {
                                  notifier.removeTasteMedia(movie.id);
                                } else {
                                  notifier.addTasteMedia(movie);
                                }
                              },
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🎬',
                                style: TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Search for titles you love',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
            ),

            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  // Progress indicator
                  Row(
                    children: [
                      Text(
                        '${state.tasteMedia.length}/3 minimum',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: state.canProceedFromTaste
                              ? AppTheme.accentGreen
                              : AppTheme.textMuted,
                        ),
                      ),
                      const Spacer(),
                      if (state.canProceedFromTaste)
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.accentGreen,
                          size: 18,
                        ),
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
                              if (context.mounted) context.go('/swipe');
                            }
                          : null,
                      child: Text(
                        state.canProceedFromTaste
                            ? 'Let\'s find your next watch 🎬'
                            : 'Add ${3 - state.tasteMedia.length} more titles',
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

class _MovieSearchTile extends StatelessWidget {
  final MediaItem movie;
  final bool isAdded;
  final VoidCallback onTap;

  const _MovieSearchTile({
    required this.movie,
    required this.isAdded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: movie.posterPath != null
            ? CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: 44,
                height: 66,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 44,
                  height: 66,
                  color: AppTheme.bgSurface,
                ),
              )
            : Container(
                width: 44,
                height: 66,
                color: AppTheme.bgSurface,
                child: const Icon(Icons.movie, color: AppTheme.textMuted),
              ),
      ),
      title: Text(
        movie.title,
        style: const TextStyle(
          fontFamily: 'Syne',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        movie.year > 0 ? '${movie.year}' : '',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppTheme.textMuted,
        ),
      ),
      trailing: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isAdded
              ? AppTheme.accentPrimary
              : AppTheme.bgElevated,
          shape: BoxShape.circle,
          border: Border.all(
            color: isAdded
                ? AppTheme.accentPrimary
                : AppTheme.bgMuted,
          ),
        ),
        child: Icon(
          isAdded ? Icons.check : Icons.add,
          size: 16,
          color: isAdded ? AppTheme.textInverse : AppTheme.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }
}
