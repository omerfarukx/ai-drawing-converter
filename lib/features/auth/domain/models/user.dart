import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../profile/domain/models/user_profile.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    required String displayName,
    String? photoURL,
    String? bio,
    @Default([]) List<String> followers,
    @Default([]) List<String> following,
    @Default(0) int drawingsCount,
    @Default(false) bool isVerified,
    required DateTime createdAt,
    required DateTime lastLoginAt,
  }) = _User;

  const User._();

  UserProfile get profile => UserProfile(
        id: id,
        email: email,
        username: username,
        displayName: displayName,
        photoURL: photoURL,
        bio: bio,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
