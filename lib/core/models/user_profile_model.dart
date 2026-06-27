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

  UserProfileModel({
    this.tasteSeedMovieIds = const [],
    this.selectedMoodIds = const [],
    this.totalSwipeCount = 0,
    this.onboardingComplete = false,
    this.gemsMode = false,
    this.swipeGateDismissed = false,
  });

  bool get hasReachedSwipeGate =>
      totalSwipeCount >= 5 && !swipeGateDismissed;
}
