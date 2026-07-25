import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_db_service.dart';

class ProfileDetails {
  final String? displayName;
  final String? avatarUrl;
  const ProfileDetails({this.displayName, this.avatarUrl});
}

class UserProfileDetailsNotifier extends StateNotifier<AsyncValue<ProfileDetails?>> {
  final Ref ref;

  UserProfileDetailsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadProfileDetails();
  }

  Future<void> loadProfileDetails() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final details = await db.getProfileDetails(user.id);
      if (details != null) {
        state = AsyncValue.data(ProfileDetails(
          displayName: details['display_name'] as String?,
          avatarUrl: details['avatar_url'] as String?,
        ));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateLocally({String? displayName, String? avatarUrl}) {
    final current = state.valueOrNull;
    state = AsyncValue.data(ProfileDetails(
      displayName: displayName ?? current?.displayName,
      avatarUrl: avatarUrl ?? current?.avatarUrl,
    ));
  }
}

final userProfileDetailsProvider =
    StateNotifierProvider<UserProfileDetailsNotifier, AsyncValue<ProfileDetails?>>(
  (ref) {
    ref.watch(currentUserProvider); // Reload if user changes
    return UserProfileDetailsNotifier(ref);
  },
);
