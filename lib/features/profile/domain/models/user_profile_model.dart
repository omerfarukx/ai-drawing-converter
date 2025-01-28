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
    @Default(0) int drawingsCount,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int savedDrawingsCount,
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

  static UserProfile fromFirestore(DocumentSnapshot doc,
      {String? currentUserId}) {
    final data = doc.data() as Map<String, dynamic>;
    final followers = List<String>.from(data['followers'] ?? []);
    final following = List<String>.from(data['following'] ?? []);
    final savedDrawings = List<String>.from(data['savedDrawings'] ?? []);

    return UserProfile(
      id: doc.id,
      username: data['username'] as String,
      displayName: data['displayName'] as String,
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      drawingsCount: (data['drawingsCount'] as num?)?.toInt() ?? 0,
      followersCount: followers.length,
      followingCount: following.length,
      savedDrawingsCount: savedDrawings.length,
      isFollowing: currentUserId != null && followers.contains(currentUserId),
    );
  }
}
