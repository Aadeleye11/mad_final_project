part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileStarted extends ProfileEvent {
  final String email;
  const ProfileStarted({required this.email});

  @override
  List<Object> get props => [email];
}

/// Saved immediately on pick, independent of the rest of the edit form.
class ProfileAvatarPicked extends ProfileEvent {
  final String path;
  const ProfileAvatarPicked(this.path);

  @override
  List<Object> get props => [path];
}

class ProfileSaved extends ProfileEvent {
  final String displayName;
  final String bio;
  final String phone;
  final String location;

  const ProfileSaved({
    required this.displayName,
    required this.bio,
    required this.phone,
    required this.location,
  });

  @override
  List<Object> get props => [displayName, bio, phone, location];
}
