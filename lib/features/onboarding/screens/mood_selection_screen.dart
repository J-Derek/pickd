import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/config/mood_config.dart';
import '../providers/onboarding_provider.dart';

class MoodSelectionScreen extends ConsumerWidget {
  const MoodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'What\'s the vibe\n$timeOfDay?',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Pick one or more moods — we\'ll find your perfect match.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              // Mood grid
              Expanded(
                child: GridView.builder(
                  itemCount: kMoods.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, index) {
                    final mood = kMoods[index];
                    final isSelected =
                        state.selectedMoodIds.contains(mood.id);
                    return _MoodCard(
                      mood: mood,
                      isSelected: isSelected,
                      onTap: () => notifier.toggleMood(mood.id),
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
                        : 'Select at least one mood',
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

class _MoodCard extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      transform: Matrix4.diagonal3Values(
          isSelected ? 1.03 : 1.0, isSelected ? 1.03 : 1.0, 1.0),
      transformAlignment: Alignment.center,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentPrimary
                  : AppTheme.bgMuted,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? AppTheme.cyanGlow : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(mood.icon, size: 32, color: isSelected ? mood.accentColor : AppTheme.textPrimary),
              const SizedBox(height: 8),
              Text(
                mood.label,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? mood.accentColor : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mood.hint,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
