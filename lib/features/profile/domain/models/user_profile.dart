import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required String username,
    required String displayName,
    String? photoURL,
    String? bio,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int drawingsCount,
    @Default(false) bool isFollowing,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
