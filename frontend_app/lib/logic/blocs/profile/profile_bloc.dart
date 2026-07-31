import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_profile.dart';
import '../../../data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileAvatarPicked>(_onAvatarPicked);
    on<ProfileSaved>(_onSaved);
  }

  void _onStarted(ProfileStarted event, Emitter<ProfileState> emit) {
    final profile = _profileRepository.getProfile(event.email);
    emit(
      state.copyWith(
        status: ProfileStatus.ready,
        email: event.email,
        profile: profile,
      ),
    );
  }

  Future<void> _onAvatarPicked(
    ProfileAvatarPicked event,
    Emitter<ProfileState> emit,
  ) async {
    final updated = state.profile.copyWith(avatarPath: event.path);
    await _profileRepository.saveProfile(state.email, updated);
    emit(state.copyWith(profile: updated));
  }

  Future<void> _onSaved(ProfileSaved event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    final updated = state.profile.copyWith(
      displayName: event.displayName,
      bio: event.bio,
      phone: event.phone,
      location: event.location,
      language: event.language,
    );
    await _profileRepository.saveProfile(state.email, updated);
    emit(state.copyWith(status: ProfileStatus.saved, profile: updated));
  }
}
