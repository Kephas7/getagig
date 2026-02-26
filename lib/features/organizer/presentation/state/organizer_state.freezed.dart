// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organizer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrganizerProfileState {
  OrganizerProfileStatus get status => throw _privateConstructorUsedError;
  OrganizerEntity? get profile => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OrganizerProfileStateCopyWith<OrganizerProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizerProfileStateCopyWith<$Res> {
  factory $OrganizerProfileStateCopyWith(OrganizerProfileState value,
          $Res Function(OrganizerProfileState) then) =
      _$OrganizerProfileStateCopyWithImpl<$Res, OrganizerProfileState>;
  @useResult
  $Res call(
      {OrganizerProfileStatus status,
      OrganizerEntity? profile,
      String? errorMessage});
}

/// @nodoc
class _$OrganizerProfileStateCopyWithImpl<$Res,
        $Val extends OrganizerProfileState>
    implements $OrganizerProfileStateCopyWith<$Res> {
  _$OrganizerProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? profile = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrganizerProfileStatus,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as OrganizerEntity?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrganizerProfileStateImplCopyWith<$Res>
    implements $OrganizerProfileStateCopyWith<$Res> {
  factory _$$OrganizerProfileStateImplCopyWith(
          _$OrganizerProfileStateImpl value,
          $Res Function(_$OrganizerProfileStateImpl) then) =
      __$$OrganizerProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {OrganizerProfileStatus status,
      OrganizerEntity? profile,
      String? errorMessage});
}

/// @nodoc
class __$$OrganizerProfileStateImplCopyWithImpl<$Res>
    extends _$OrganizerProfileStateCopyWithImpl<$Res,
        _$OrganizerProfileStateImpl>
    implements _$$OrganizerProfileStateImplCopyWith<$Res> {
  __$$OrganizerProfileStateImplCopyWithImpl(_$OrganizerProfileStateImpl _value,
      $Res Function(_$OrganizerProfileStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? profile = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$OrganizerProfileStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrganizerProfileStatus,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as OrganizerEntity?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OrganizerProfileStateImpl implements _OrganizerProfileState {
  const _$OrganizerProfileStateImpl(
      {this.status = OrganizerProfileStatus.initial,
      this.profile,
      this.errorMessage});

  @override
  @JsonKey()
  final OrganizerProfileStatus status;
  @override
  final OrganizerEntity? profile;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'OrganizerProfileState(status: $status, profile: $profile, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizerProfileStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, profile, errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizerProfileStateImplCopyWith<_$OrganizerProfileStateImpl>
      get copyWith => __$$OrganizerProfileStateImplCopyWithImpl<
          _$OrganizerProfileStateImpl>(this, _$identity);
}

abstract class _OrganizerProfileState implements OrganizerProfileState {
  const factory _OrganizerProfileState(
      {final OrganizerProfileStatus status,
      final OrganizerEntity? profile,
      final String? errorMessage}) = _$OrganizerProfileStateImpl;

  @override
  OrganizerProfileStatus get status;
  @override
  OrganizerEntity? get profile;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$OrganizerProfileStateImplCopyWith<_$OrganizerProfileStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
