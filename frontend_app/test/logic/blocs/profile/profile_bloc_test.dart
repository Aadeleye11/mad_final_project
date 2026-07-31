import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend_app/data/models/user_profile.dart';
import 'package:frontend_app/data/repositories/profile_repository.dart';
import 'package:frontend_app/logic/blocs/profile/profile_bloc.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  const email = 'emeka@example.com';
  const savedProfile = UserProfile(
    displayName: 'Emeka Daniels',
    bio: 'Loves gorillas.',
    location: 'Kigali',
  );

  setUpAll(() {
    registerFallbackValue(const UserProfile());
  });

  setUp(() {
    repository = MockProfileRepository();
    when(() => repository.saveProfile(any(), any())).thenAnswer((_) async {});
  });

  blocTest<ProfileBloc, ProfileState>(
    'loads the saved profile for the given email',
    build: () {
      when(() => repository.getProfile(email)).thenReturn(savedProfile);
      return ProfileBloc(repository);
    },
    act: (bloc) => bloc.add(const ProfileStarted(email: email)),
    expect: () => [
      const ProfileState(
        status: ProfileStatus.ready,
        email: email,
        profile: savedProfile,
      ),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'defaults to an empty profile when nothing is saved yet',
    build: () {
      when(() => repository.getProfile(email)).thenReturn(const UserProfile());
      return ProfileBloc(repository);
    },
    act: (bloc) => bloc.add(const ProfileStarted(email: email)),
    expect: () => [
      const ProfileState(status: ProfileStatus.ready, email: email),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'saves and applies edited fields',
    build: () {
      when(() => repository.getProfile(email)).thenReturn(savedProfile);
      return ProfileBloc(repository);
    },
    act: (bloc) => bloc
      ..add(const ProfileStarted(email: email))
      ..add(
        const ProfileSaved(
          displayName: 'Emeka D.',
          bio: 'Updated bio.',
          phone: '+250123456789',
          location: 'Musanze',
        ),
      ),
    expect: () => [
      ProfileState(
        status: ProfileStatus.ready,
        email: email,
        profile: savedProfile,
      ),
      ProfileState(
        status: ProfileStatus.saving,
        email: email,
        profile: savedProfile,
      ),
      const ProfileState(
        status: ProfileStatus.saved,
        email: email,
        profile: UserProfile(
          displayName: 'Emeka D.',
          bio: 'Updated bio.',
          phone: '+250123456789',
          location: 'Musanze',
        ),
      ),
    ],
    verify: (_) {
      verify(
        () => repository.saveProfile(
          email,
          const UserProfile(
            displayName: 'Emeka D.',
            bio: 'Updated bio.',
            phone: '+250123456789',
            location: 'Musanze',
          ),
        ),
      ).called(1);
    },
  );

  blocTest<ProfileBloc, ProfileState>(
    'saves a picked avatar path immediately',
    build: () {
      when(() => repository.getProfile(email)).thenReturn(const UserProfile());
      return ProfileBloc(repository);
    },
    act: (bloc) => bloc
      ..add(const ProfileStarted(email: email))
      ..add(const ProfileAvatarPicked('/tmp/avatar.jpg')),
    expect: () => [
      const ProfileState(status: ProfileStatus.ready, email: email),
      const ProfileState(
        status: ProfileStatus.ready,
        email: email,
        profile: UserProfile(avatarPath: '/tmp/avatar.jpg'),
      ),
    ],
  );
}
