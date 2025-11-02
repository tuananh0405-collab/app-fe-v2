import '../../domain/entities/profile_entity.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  factory ProfileState.initial() => const ProfileState();
  
  factory ProfileState.loading() => const ProfileState(status: ProfileStatus.loading);
  
  factory ProfileState.loaded(ProfileEntity profile) => ProfileState(
        status: ProfileStatus.loaded,
        profile: profile,
      );
  
  factory ProfileState.error(String message) => ProfileState(
        status: ProfileStatus.error,
        errorMessage: message,
      );

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
