// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) {
  return _ConversationModel.fromJson(json);
}

/// @nodoc
mixin _$ConversationModel {
  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  String? get id => throw _privateConstructorUsedError;
  @HiveField(1)
  List<AuthApiModel> get participants => throw _privateConstructorUsedError;
  @HiveField(2)
  String? get lastMessage => throw _privateConstructorUsedError;
  @HiveField(3)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @HiveField(4)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConversationModelCopyWith<ConversationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationModelCopyWith<$Res> {
  factory $ConversationModelCopyWith(
          ConversationModel value, $Res Function(ConversationModel) then) =
      _$ConversationModelCopyWithImpl<$Res, ConversationModel>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id', readValue: _readId) String? id,
      @HiveField(1) List<AuthApiModel> participants,
      @HiveField(2) String? lastMessage,
      @HiveField(3) DateTime? createdAt,
      @HiveField(4) DateTime? updatedAt});
}

/// @nodoc
class _$ConversationModelCopyWithImpl<$Res, $Val extends ConversationModel>
    implements $ConversationModelCopyWith<$Res> {
  _$ConversationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? participants = null,
    Object? lastMessage = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<AuthApiModel>,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationModelImplCopyWith<$Res>
    implements $ConversationModelCopyWith<$Res> {
  factory _$$ConversationModelImplCopyWith(_$ConversationModelImpl value,
          $Res Function(_$ConversationModelImpl) then) =
      __$$ConversationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id', readValue: _readId) String? id,
      @HiveField(1) List<AuthApiModel> participants,
      @HiveField(2) String? lastMessage,
      @HiveField(3) DateTime? createdAt,
      @HiveField(4) DateTime? updatedAt});
}

/// @nodoc
class __$$ConversationModelImplCopyWithImpl<$Res>
    extends _$ConversationModelCopyWithImpl<$Res, _$ConversationModelImpl>
    implements _$$ConversationModelImplCopyWith<$Res> {
  __$$ConversationModelImplCopyWithImpl(_$ConversationModelImpl _value,
      $Res Function(_$ConversationModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? participants = null,
    Object? lastMessage = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ConversationModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<AuthApiModel>,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(
    typeId: HiveTableConstant.conversationTypeId,
    adapterName: 'ConversationModelAdapter')
class _$ConversationModelImpl implements _ConversationModel {
  const _$ConversationModelImpl(
      {@HiveField(0) @JsonKey(name: '_id', readValue: _readId) this.id,
      @HiveField(1) final List<AuthApiModel> participants = const [],
      @HiveField(2) this.lastMessage,
      @HiveField(3) this.createdAt,
      @HiveField(4) this.updatedAt})
      : _participants = participants;

  factory _$ConversationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationModelImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  final String? id;
  final List<AuthApiModel> _participants;
  @override
  @JsonKey()
  @HiveField(1)
  List<AuthApiModel> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  @HiveField(2)
  final String? lastMessage;
  @override
  @HiveField(3)
  final DateTime? createdAt;
  @override
  @HiveField(4)
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ConversationModel(id: $id, participants: $participants, lastMessage: $lastMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_participants),
      lastMessage,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationModelImplCopyWith<_$ConversationModelImpl> get copyWith =>
      __$$ConversationModelImplCopyWithImpl<_$ConversationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationModelImplToJson(
      this,
    );
  }
}

abstract class _ConversationModel implements ConversationModel {
  const factory _ConversationModel(
      {@HiveField(0) @JsonKey(name: '_id', readValue: _readId) final String? id,
      @HiveField(1) final List<AuthApiModel> participants,
      @HiveField(2) final String? lastMessage,
      @HiveField(3) final DateTime? createdAt,
      @HiveField(4) final DateTime? updatedAt}) = _$ConversationModelImpl;

  factory _ConversationModel.fromJson(Map<String, dynamic> json) =
      _$ConversationModelImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: '_id', readValue: _readId)
  String? get id;
  @override
  @HiveField(1)
  List<AuthApiModel> get participants;
  @override
  @HiveField(2)
  String? get lastMessage;
  @override
  @HiveField(3)
  DateTime? get createdAt;
  @override
  @HiveField(4)
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ConversationModelImplCopyWith<_$ConversationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
