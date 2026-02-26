// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gigs_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GigsState {
  GigsStatus get status => throw _privateConstructorUsedError;
  List<GigEntity> get gigs => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GigsStateCopyWith<GigsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GigsStateCopyWith<$Res> {
  factory $GigsStateCopyWith(GigsState value, $Res Function(GigsState) then) =
      _$GigsStateCopyWithImpl<$Res, GigsState>;
  @useResult
  $Res call({GigsStatus status, List<GigEntity> gigs, String? errorMessage});
}

/// @nodoc
class _$GigsStateCopyWithImpl<$Res, $Val extends GigsState>
    implements $GigsStateCopyWith<$Res> {
  _$GigsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? gigs = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GigsStatus,
      gigs: null == gigs
          ? _value.gigs
          : gigs // ignore: cast_nullable_to_non_nullable
              as List<GigEntity>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GigsStateImplCopyWith<$Res>
    implements $GigsStateCopyWith<$Res> {
  factory _$$GigsStateImplCopyWith(
          _$GigsStateImpl value, $Res Function(_$GigsStateImpl) then) =
      __$$GigsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GigsStatus status, List<GigEntity> gigs, String? errorMessage});
}

/// @nodoc
class __$$GigsStateImplCopyWithImpl<$Res>
    extends _$GigsStateCopyWithImpl<$Res, _$GigsStateImpl>
    implements _$$GigsStateImplCopyWith<$Res> {
  __$$GigsStateImplCopyWithImpl(
      _$GigsStateImpl _value, $Res Function(_$GigsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? gigs = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$GigsStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GigsStatus,
      gigs: null == gigs
          ? _value._gigs
          : gigs // ignore: cast_nullable_to_non_nullable
              as List<GigEntity>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GigsStateImpl implements _GigsState {
  const _$GigsStateImpl(
      {this.status = GigsStatus.initial,
      final List<GigEntity> gigs = const [],
      this.errorMessage})
      : _gigs = gigs;

  @override
  @JsonKey()
  final GigsStatus status;
  final List<GigEntity> _gigs;
  @override
  @JsonKey()
  List<GigEntity> get gigs {
    if (_gigs is EqualUnmodifiableListView) return _gigs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gigs);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'GigsState(status: $status, gigs: $gigs, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GigsStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._gigs, _gigs) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status,
      const DeepCollectionEquality().hash(_gigs), errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GigsStateImplCopyWith<_$GigsStateImpl> get copyWith =>
      __$$GigsStateImplCopyWithImpl<_$GigsStateImpl>(this, _$identity);
}

abstract class _GigsState implements GigsState {
  const factory _GigsState(
      {final GigsStatus status,
      final List<GigEntity> gigs,
      final String? errorMessage}) = _$GigsStateImpl;

  @override
  GigsStatus get status;
  @override
  List<GigEntity> get gigs;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$GigsStateImplCopyWith<_$GigsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
