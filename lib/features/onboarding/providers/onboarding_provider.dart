import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/media_item.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/services/supabase_db_service.dart';

/// State for the onboarding flow
class OnboardingState {
  final List<String> selectedMoodIds;
  final List<MediaItem> tasteMedia;
  final int step; // 0 = mood, 1 = taste

  const OnboardingState({
    this.selectedMoodIds = const [],
    this.tasteMedia = const [],
    this.step = 0,
  });

  OnboardingState copyWith({
    List<String>? selectedMoodIds,
    List<MediaItem>? tasteMedia,
    int? step,
  }) {
    return OnboardingState(
      selectedMoodIds: selectedMoodIds ?? this.selectedMoodIds,
      tasteMedia: tasteMedia ?? this.tasteMedia,
      step: step ?? this.step,
    );
  }

  bool get canProceedFromMood => selectedMoodIds.isNotEmpty;
  bool get canProceedFromTaste => tasteMedia.length >= 3;
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref ref;

  OnboardingNotifier(this.ref) : super(const OnboardingState());

  void toggleMood(String moodId) {
    final current = List<String>.from(state.selectedMoodIds);
    if (current.contains(moodId)) {
      current.remove(moodId);
    } else {
      current.add(moodId);
    }
    state = state.copyWith(selectedMoodIds: current);
  }

  void addTasteMedia(MediaItem media) {
    if (state.tasteMedia.any((m) => m.id == media.id)) return;
    if (state.tasteMedia.length >= 10) return;
    state = state.copyWith(
      tasteMedia: [...state.tasteMedia, media],
    );
  }

  void removeTasteMedia(int mediaId) {
    state = state.copyWith(
      tasteMedia: state.tasteMedia.where((m) => m.id != mediaId).toList(),
    );
  }

  /// Persist onboarding selections to Hive and mark complete
  Future<void> completeOnboarding() async {
    final profile = HiveService.getProfile();
    
    final movieIds = state.tasteMedia
        .where((m) => m.isMovie)
        .map((m) => m.id)
        .toList();
        
    final tvIds = state.tasteMedia
        .where((m) => m.isTv)
        .map((m) => m.id)
        .toList();
        
    profile.tasteSeedMovieIds = movieIds;
    profile.tasteSeedTvIds = tvIds;
    profile.selectedMoodIds = state.selectedMoodIds;
    profile.onboardingComplete = true;
    await HiveService.saveProfile(profile);

    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(supabaseDbServiceProvider).syncTasteSeeds(user.id, movieIds, tvIds);
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(ref),
);
