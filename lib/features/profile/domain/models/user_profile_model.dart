import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

DateTime? _dateTimeFromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  return null;
}

dynamic _dateTimeToTimestamp(DateTime? date) {
  if (date == null) return null;
  return Timestamp.fromDate(date);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String username,
    required String displayName,
    @JsonKey(name: 'photoURL') String? photoUrl,
    String? bio,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int drawingsCount,
    @Default(false) bool isFollowing,
    @Default([]) List<String> followers,
    @Default([]) List<String> following,
    @JsonKey(
      fromJson: _dateTimeFromTimestamp,
      toJson: _dateTimeToTimestamp,
    )
    DateTime? createdAt,
    @JsonKey(
      fromJson: _dateTimeFromTimestamp,
      toJson: _dateTimeToTimestamp,
    )
    DateTime? lastLoginAt,
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
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
}
