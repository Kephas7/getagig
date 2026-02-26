// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  String? get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String? get userId => throw _privateConstructorUsedError;
  @HiveField(2)
  String get type => throw _privateConstructorUsedError;
  @HiveField(3)
  String get title => throw _privateConstructorUsedError;
  @HiveField(4)
  String get content => throw _privateConstructorUsedError;
  @HiveField(5)
  String? get relatedId => throw _privateConstructorUsedError;
  @HiveField(6)
  bool get isRead => throw _privateConstructorUsedError;
  @HiveField(7)
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
          NotificationModel value, $Res Function(NotificationModel) then) =
      _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id', readValue: _readId) String? id,
      @HiveField(1) String? userId,
      @HiveField(2) String type,
      @HiveField(3) String title,
      @HiveField(4) String content,
      @HiveField(5) String? relatedId,
      @HiveField(6) bool isRead,
      @HiveField(7) DateTime? createdAt});
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? type = null,
    Object? title = null,
    Object? content = null,
    Object? relatedId = freezed,
    Object? isRead = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      relatedId: freezed == relatedId
          ? _value.relatedId
          : relatedId // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(_$NotificationModelImpl value,
          $Res Function(_$NotificationModelImpl) then) =
      __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id', readValue: _readId) String? id,
      @HiveField(1) String? userId,
      @HiveField(2) String type,
      @HiveField(3) String title,
      @HiveField(4) String content,
      @HiveField(5) String? relatedId,
      @HiveField(6) bool isRead,
      @HiveField(7) DateTime? createdAt});
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(_$NotificationModelImpl _value,
      $Res Function(_$NotificationModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? type = null,
    Object? title = null,
    Object? content = null,
    Object? relatedId = freezed,
    Object? isRead = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$NotificationModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      relatedId: freezed == relatedId
          ? _value.relatedId
          : relatedId // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(
    typeId: HiveTableConstant.notificationTypeId,
    adapterName: 'NotificationModelAdapter')
class _$NotificationModelImpl implements _NotificationModel {
  const _$NotificationModelImpl(
      {@HiveField(0) @JsonKey(name: '_id', readValue: _readId) this.id,
      @HiveField(1) this.userId,
      @HiveField(2) required this.type,
      @HiveField(3) required this.title,
      @HiveField(4) required this.content,
      @HiveField(5) this.relatedId,
      @HiveField(6) this.isRead = false,
      @HiveField(7) this.createdAt});

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  final String? id;
  @override
  @HiveField(1)
  final String? userId;
  @override
  @HiveField(2)
  final String type;
  @override
  @HiveField(3)
  final String title;
  @override
  @HiveField(4)
  final String content;
  @override
  @HiveField(5)
  final String? relatedId;
  @override
  @JsonKey()
  @HiveField(6)
  final bool isRead;
  @override
  @HiveField(7)
  final DateTime? createdAt;

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, type: $type, title: $title, content: $content, relatedId: $relatedId, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.relatedId, relatedId) ||
                other.relatedId == relatedId) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, type, title, content,
      relatedId, isRead, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationModel implements NotificationModel {
  const factory _NotificationModel(
      {@HiveField(0) @JsonKey(name: '_id', readValue: _readId) final String? id,
      @HiveField(1) final String? userId,
      @HiveField(2) required final String type,
      @HiveField(3) required final String title,
      @HiveField(4) required final String content,
      @HiveField(5) final String? relatedId,
      @HiveField(6) final bool isRead,
      @HiveField(7) final DateTime? createdAt}) = _$NotificationModelImpl;

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  String? get id;
  @override
  @HiveField(1)
  String? get userId;
  @override
  @HiveField(2)
  String get type;
  @override
  @HiveField(3)
  String get title;
  @override
  @HiveField(4)
  String get content;
  @override
  @HiveField(5)
  String? get relatedId;
  @override
  @HiveField(6)
  bool get isRead;
  @override
  @HiveField(7)
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
