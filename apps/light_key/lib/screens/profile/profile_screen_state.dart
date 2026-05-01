import '../../models/user_profile.dart';

enum ProfileStatus { idle, loading, loaded, error }

class ProfileScreenState {
  const ProfileScreenState({required this.status, this.profile, this.message});

  const ProfileScreenState.idle()
    : status = ProfileStatus.idle,
      profile = null,
      message = null;

  final ProfileStatus status;
  final UserProfile? profile;
  final String? message;

  ProfileScreenState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? message,
    bool clearMessage = false,
    bool clearProfile = false,
  }) {
    return ProfileScreenState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
