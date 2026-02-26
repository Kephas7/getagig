// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'musician_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MusicianProfileState {
  MusicianProfileStatus get status => throw _privateConstructorUsedError;
  MusicianEntity? get profile => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MusicianProfileStateCopyWith<MusicianProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MusicianProfileStateCopyWith<$Res> {
  factory $MusicianProfileStateCopyWith(MusicianProfileState value,
          $Res Function(MusicianProfileState) then) =
      _$MusicianProfileStateCopyWithImpl<$Res, MusicianProfileState>;
  @useResult
  $Res call(
      {MusicianProfileStatus status,
      MusicianEntity? profile,
      String? errorMessage});
}

/// @nodoc
class _$MusicianProfileStateCopyWithImpl<$Res,
        $Val extends MusicianProfileState>
    implements $MusicianProfileStateCopyWith<$Res> {
  _$MusicianProfileStateCopyWithImpl(this._value, this._then);

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
              as MusicianProfileStatus,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as MusicianEntity?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MusicianProfileStateImplCopyWith<$Res>
    implements $MusicianProfileStateCopyWith<$Res> {
  factory _$$MusicianProfileStateImplCopyWith(_$MusicianProfileStateImpl value,
          $Res Function(_$MusicianProfileStateImpl) then) =
      __$$MusicianProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MusicianProfileStatus status,
      MusicianEntity? profile,
      String? errorMessage});
}

/// @nodoc
class __$$MusicianProfileStateImplCopyWithImpl<$Res>
    extends _$MusicianProfileStateCopyWithImpl<$Res, _$MusicianProfileStateImpl>
    implements _$$MusicianProfileStateImplCopyWith<$Res> {
  __$$MusicianProfileStateImplCopyWithImpl(_$MusicianProfileStateImpl _value,
      $Res Function(_$MusicianProfileStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? profile = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$MusicianProfileStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MusicianProfileStatus,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as MusicianEntity?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MusicianProfileStateImpl implements _MusicianProfileState {
  const _$MusicianProfileStateImpl(
      {this.status = MusicianProfileStatus.initial,
      this.profile,
      this.errorMessage});

  @override
  @JsonKey()
  final MusicianProfileStatus status;
  @override
  final MusicianEntity? profile;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'MusicianProfileState(status: $status, profile: $profile, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MusicianProfileStateImpl &&
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
  _$$MusicianProfileStateImplCopyWith<_$MusicianProfileStateImpl>
      get copyWith =>
          __$$MusicianProfileStateImplCopyWithImpl<_$MusicianProfileStateImpl>(
              this, _$identity);
}

abstract class _MusicianProfileState implements MusicianProfileState {
  const factory _MusicianProfileState(
      {final MusicianProfileStatus status,
      final MusicianEntity? profile,
      final String? errorMessage}) = _$MusicianProfileStateImpl;

  @override
  MusicianProfileStatus get status;
  @override
  MusicianEntity? get profile;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$MusicianProfileStateImplCopyWith<_$MusicianProfileStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
