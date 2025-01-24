import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String username,
    required String displayName,
    String? profileImage,
    String? bio,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int drawingsCount,
    @Default(false) bool isFollowing,
    @Default([]) List<String> followers,
    @Default([]) List<String> following,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  factory UserProfile.defaultProfile({
    required String id,
    required String username,
  }) =>
      UserProfile(
        id: id,
        username: username,
        displayName: 'Yeni Kullanıcı',
        bio: 'Merhaba! Ben yeni bir kullanıcıyım.',
      );
}
