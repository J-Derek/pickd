import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/config/mood_config.dart';
import '../providers/onboarding_provider.dart';

class MoodSelectionScreen extends ConsumerStatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  ConsumerState<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends ConsumerState<MoodSelectionScreen> {
  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Dynamic time of day
    final hour = DateTime.now().hour;
    String timeOfDay;
    if (hour >= 5 && hour < 12) {
      timeOfDay = 'this morning';
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = 'this afternoon';
    } else if (hour >= 17 && hour < 21) {
      timeOfDay = 'this evening';
    } else {
      timeOfDay = 'tonight';
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: context.canPop() ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ) : null,
        actions: [
          IconButton(
            icon: Icon(
              _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppTheme.textSecondary,
            ),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'What\'s your vibe\n$timeOfDay?',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Select one or more genres to build your feed.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              // Genre grid
              Expanded(
                child: _isGrid
                    ? GridView.builder(
                        itemCount: kGenres.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4,
                        ),
                        itemBuilder: (context, index) {
                          final genre = kGenres[index];
                          final isSelected =
                              state.selectedMoodIds.contains(genre.id.toString());
                          return _GenreCard(
                            genre: genre,
                            isSelected: isSelected,
                            onTap: () => notifier.toggleMood(genre.id.toString()),
                          );
                        },
                      )
                    : ListView.separated(
                        itemCount: kGenres.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final genre = kGenres[index];
                          final isSelected =
                              state.selectedMoodIds.contains(genre.id.toString());
                          return _GenreListTile(
                            genre: genre,
                            isSelected: isSelected,
                            onTap: () => notifier.toggleMood(genre.id.toString()),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              // CTA
              AnimatedOpacity(
                opacity: state.canProceedFromMood ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: state.canProceedFromMood
                      ? () => context.push('/onboarding/taste')
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                  ),
                  child: Text(
                    state.canProceedFromMood
                        ? 'Next — Pick your favourites'
                        : 'Select at least one genre',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  final GenreItem genre;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenreCard({
    required this.genre,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      transform: Matrix4.diagonal3Values(
          isSelected ? 1.02 : 1.0, isSelected ? 1.02 : 1.0, 1.0),
      transformAlignment: Alignment.center,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.bgElevated : AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentPrimary
                  : AppTheme.bgMuted,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                genre.icon,
                size: 28,
                color: isSelected ? genre.accentColor : AppTheme.textSecondary,
              ),
              const SizedBox(height: 10),
              Text(
                genre.label,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreListTile extends StatelessWidget {
  final GenreItem genre;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenreListTile({
    required this.genre,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.bgElevated : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentPrimary : AppTheme.bgMuted,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              genre.icon,
              size: 24,
              color: isSelected ? genre.accentColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: 16),
            Text(
              genre.label,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.accentPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
