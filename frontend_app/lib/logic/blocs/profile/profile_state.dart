part of 'profile_bloc.dart';

enum ProfileStatus { initial, ready, saving, saved }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String email;
  final UserProfile profile;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.email = '',
    this.profile = const UserProfile(),
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? email,
    UserProfile? profile,
  }) {
    return ProfileState(
      status: status ?? this.status,
      email: email ?? this.email,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object> get props => [status, email, profile];
}
