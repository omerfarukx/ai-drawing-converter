import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    String? displayName,
    String? photoURL,
    String? bio,
    @Default([]) List<String> followers,
    @Default([]) List<String> following,
    @Default(0) int drawingsCount,
    @Default(false) bool isVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
