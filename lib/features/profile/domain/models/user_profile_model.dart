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
    @Default('Yeni Kullanıcı') String displayName,
    @JsonKey(name: 'photoURL') String? photoUrl,
    @Default('Merhaba! Ben yeni bir kullanıcıyım.') String bio,
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
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

  static UserProfile fromFirestore(DocumentSnapshot doc,
      {String? currentUserId}) {
    final data = doc.data() as Map<String, dynamic>;
    final followers = List<String>.from(data['followers'] ?? []);
    final following = List<String>.from(data['following'] ?? []);

    return UserProfile(
      id: doc.id,
      username: data['username'] as String? ?? 'user_${doc.id.substring(0, 8)}',
      displayName: data['displayName'] as String? ?? 'Yeni Kullanıcı',
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String? ?? 'Merhaba! Ben yeni bir kullanıcıyım.',
      drawingsCount: (data['drawingsCount'] as num?)?.toInt() ?? 0,
      followersCount: (data['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
      savedDrawingsCount: (data['savedDrawingsCount'] as num?)?.toInt() ?? 0,
      isFollowing:
          currentUserId != null ? following.contains(currentUserId) : false,
      followers: followers,
      following: following,
      createdAt: _dateTimeFromTimestamp(data['createdAt']),
      lastLoginAt: _dateTimeFromTimestamp(data['lastLoginAt']),
    );
  }
}
