// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drawing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Drawing _$DrawingFromJson(Map<String, dynamic> json) {
  return _Drawing.fromJson(json);
}

/// @nodoc
mixin _$Drawing {
  String get id => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DrawingCopyWith<Drawing> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DrawingCopyWith<$Res> {
  factory $DrawingCopyWith(Drawing value, $Res Function(Drawing) then) =
      _$DrawingCopyWithImpl<$Res, Drawing>;
  @useResult
  $Res call(
      {String id,
      String path,
      DateTime createdAt,
      String category,
      String? title,
      String? description});
}

/// @nodoc
class _$DrawingCopyWithImpl<$Res, $Val extends Drawing>
    implements $DrawingCopyWith<$Res> {
  _$DrawingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? createdAt = null,
    Object? category = null,
    Object? title = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DrawingImplCopyWith<$Res> implements $DrawingCopyWith<$Res> {
  factory _$$DrawingImplCopyWith(
          _$DrawingImpl value, $Res Function(_$DrawingImpl) then) =
      __$$DrawingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String path,
      DateTime createdAt,
      String category,
      String? title,
      String? description});
}

/// @nodoc
class __$$DrawingImplCopyWithImpl<$Res>
    extends _$DrawingCopyWithImpl<$Res, _$DrawingImpl>
    implements _$$DrawingImplCopyWith<$Res> {
  __$$DrawingImplCopyWithImpl(
      _$DrawingImpl _value, $Res Function(_$DrawingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? createdAt = null,
    Object? category = null,
    Object? title = freezed,
    Object? description = freezed,
  }) {
    return _then(_$DrawingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DrawingImpl implements _Drawing {
  const _$DrawingImpl(
      {required this.id,
      required this.path,
      required this.createdAt,
      required this.category,
      this.title,
      this.description});

  factory _$DrawingImpl.fromJson(Map<String, dynamic> json) =>
      _$$DrawingImplFromJson(json);

  @override
  final String id;
  @override
  final String path;
  @override
  final DateTime createdAt;
  @override
  final String category;
  @override
  final String? title;
  @override
  final String? description;

  @override
  String toString() {
    return 'Drawing(id: $id, path: $path, createdAt: $createdAt, category: $category, title: $title, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DrawingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, path, createdAt, category, title, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DrawingImplCopyWith<_$DrawingImpl> get copyWith =>
      __$$DrawingImplCopyWithImpl<_$DrawingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DrawingImplToJson(
      this,
    );
  }
}

abstract class _Drawing implements Drawing {
  const factory _Drawing(
      {required final String id,
      required final String path,
      required final DateTime createdAt,
      required final String category,
      final String? title,
      final String? description}) = _$DrawingImpl;

  factory _Drawing.fromJson(Map<String, dynamic> json) = _$DrawingImpl.fromJson;

  @override
  String get id;
  @override
  String get path;
  @override
  DateTime get createdAt;
  @override
  String get category;
  @override
  String? get title;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$DrawingImplCopyWith<_$DrawingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
