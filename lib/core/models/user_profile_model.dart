import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 1)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  List<int> tasteSeedMovieIds;

  @HiveField(1)
  List<String> selectedMoodIds;

  @HiveField(2)
  int totalSwipeCount;

  @HiveField(3)
  bool onboardingComplete;

  @HiveField(4)
  bool gemsMode;

  @HiveField(5)
  bool swipeGateDismissed;

  @HiveField(6, defaultValue: [])
  List<int> tasteSeedTvIds;

  @HiveField(7, defaultValue: false)
  bool allowOldMovies;

  @HiveField(8, defaultValue: false)
  bool hasSeenWalkthrough;

  UserProfileModel({
    this.tasteSeedMovieIds = const [],
    this.tasteSeedTvIds = const [],
    this.selectedMoodIds = const [],
    this.totalSwipeCount = 0,
    this.onboardingComplete = false,
    this.gemsMode = false,
    this.swipeGateDismissed = false,
    this.allowOldMovies = false,
    this.hasSeenWalkthrough = false,
  });

  bool get hasReachedSwipeGate =>
      totalSwipeCount >= 5 && !swipeGateDismissed;
}
