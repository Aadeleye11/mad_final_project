import 'package:equatable/equatable.dart';

/// Editable profile details, kept separate from the account's [User] record
/// so profile editing never has to touch auth code.
class UserProfile extends Equatable {
  final String displayName;
  final String bio;
  final String phone;
  final String location;
  final String avatarPath;

  const UserProfile({
    this.displayName = '',
    this.bio = '',
    this.phone = '',
    this.location = '',
    this.avatarPath = '',
  });

  bool get hasAvatar => avatarPath.isNotEmpty;

  UserProfile copyWith({
    String? displayName,
    String? bio,
    String? phone,
    String? location,
    String? avatarPath,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['displayName'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      avatarPath: json['avatarPath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'bio': bio,
    'phone': phone,
    'location': location,
    'avatarPath': avatarPath,
  };

  @override
  List<Object?> get props => [displayName, bio, phone, location, avatarPath];
}
