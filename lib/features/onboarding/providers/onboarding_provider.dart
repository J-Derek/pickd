import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/movie_model.dart';
import '../../../core/services/hive_service.dart';

/// State for the onboarding flow
class OnboardingState {
  final List<String> selectedMoodIds;
  final List<MovieModel> tasteMovies;
  final int step; // 0 = mood, 1 = taste

  const OnboardingState({
    this.selectedMoodIds = const [],
    this.tasteMovies = const [],
    this.step = 0,
  });

  OnboardingState copyWith({
    List<String>? selectedMoodIds,
    List<MovieModel>? tasteMovies,
    int? step,
  }) {
    return OnboardingState(
      selectedMoodIds: selectedMoodIds ?? this.selectedMoodIds,
      tasteMovies: tasteMovies ?? this.tasteMovies,
      step: step ?? this.step,
    );
  }

  bool get canProceedFromMood => selectedMoodIds.isNotEmpty;
  bool get canProceedFromTaste => tasteMovies.length >= 3;
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void toggleMood(String moodId) {
    final current = List<String>.from(state.selectedMoodIds);
    if (current.contains(moodId)) {
      current.remove(moodId);
    } else {
      current.add(moodId);
    }
    state = state.copyWith(selectedMoodIds: current);
  }

  void addTasteMovie(MovieModel movie) {
    if (state.tasteMovies.any((m) => m.id == movie.id)) return;
    if (state.tasteMovies.length >= 10) return;
    state = state.copyWith(
      tasteMovies: [...state.tasteMovies, movie],
    );
  }

  void removeTasteMovie(int movieId) {
    state = state.copyWith(
      tasteMovies: state.tasteMovies.where((m) => m.id != movieId).toList(),
    );
  }

  /// Persist onboarding selections to Hive and mark complete
  Future<void> completeOnboarding() async {
    final profile = HiveService.getProfile();
    profile.tasteSeedMovieIds =
        state.tasteMovies.map((m) => m.id).toList();
    profile.selectedMoodIds = state.selectedMoodIds;
    profile.onboardingComplete = true;
    await HiveService.saveProfile(profile);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
