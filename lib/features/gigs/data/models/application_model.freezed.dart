// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ApplicationModel _$ApplicationModelFromJson(Map<String, dynamic> json) {
  return _ApplicationModel.fromJson(json);
}

/// @nodoc
mixin _$ApplicationModel {
  @JsonKey(name: '_id', readValue: _readId)
  String? get id => throw _privateConstructorUsedError;
  String? get gigId => throw _privateConstructorUsedError;
  String? get musicianId => throw _privateConstructorUsedError;
  GigModel? get gig => throw _privateConstructorUsedError;
  AuthApiModel? get musician => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get coverLetter => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApplicationModelCopyWith<ApplicationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApplicationModelCopyWith<$Res> {
  factory $ApplicationModelCopyWith(
          ApplicationModel value, $Res Function(ApplicationModel) then) =
      _$ApplicationModelCopyWithImpl<$Res, ApplicationModel>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id', readValue: _readId) String? id,
      String? gigId,
      String? musicianId,
      GigModel? gig,
      AuthApiModel? musician,
      String status,
      String coverLetter,
      DateTime? createdAt});

  $GigModelCopyWith<$Res>? get gig;
  $AuthApiModelCopyWith<$Res>? get musician;
}

/// @nodoc
class _$ApplicationModelCopyWithImpl<$Res, $Val extends ApplicationModel>
    implements $ApplicationModelCopyWith<$Res> {
  _$ApplicationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? gigId = freezed,
    Object? musicianId = freezed,
    Object? gig = freezed,
    Object? musician = freezed,
    Object? status = null,
    Object? coverLetter = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      gigId: freezed == gigId
          ? _value.gigId
          : gigId // ignore: cast_nullable_to_non_nullable
              as String?,
      musicianId: freezed == musicianId
          ? _value.musicianId
          : musicianId // ignore: cast_nullable_to_non_nullable
              as String?,
      gig: freezed == gig
          ? _value.gig
          : gig // ignore: cast_nullable_to_non_nullable
              as GigModel?,
      musician: freezed == musician
          ? _value.musician
          : musician // ignore: cast_nullable_to_non_nullable
              as AuthApiModel?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      coverLetter: null == coverLetter
          ? _value.coverLetter
          : coverLetter // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GigModelCopyWith<$Res>? get gig {
    if (_value.gig == null) {
      return null;
    }

    return $GigModelCopyWith<$Res>(_value.gig!, (value) {
      return _then(_value.copyWith(gig: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthApiModelCopyWith<$Res>? get musician {
    if (_value.musician == null) {
      return null;
    }

    return $AuthApiModelCopyWith<$Res>(_value.musician!, (value) {
      return _then(_value.copyWith(musician: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApplicationModelImplCopyWith<$Res>
    implements $ApplicationModelCopyWith<$Res> {
  factory _$$ApplicationModelImplCopyWith(_$ApplicationModelImpl value,
          $Res Function(_$ApplicationModelImpl) then) =
      __$$ApplicationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id', readValue: _readId) String? id,
      String? gigId,
      String? musicianId,
      GigModel? gig,
      AuthApiModel? musician,
      String status,
      String coverLetter,
      DateTime? createdAt});

  @override
  $GigModelCopyWith<$Res>? get gig;
  @override
  $AuthApiModelCopyWith<$Res>? get musician;
}

/// @nodoc
class __$$ApplicationModelImplCopyWithImpl<$Res>
    extends _$ApplicationModelCopyWithImpl<$Res, _$ApplicationModelImpl>
    implements _$$ApplicationModelImplCopyWith<$Res> {
  __$$ApplicationModelImplCopyWithImpl(_$ApplicationModelImpl _value,
      $Res Function(_$ApplicationModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? gigId = freezed,
    Object? musicianId = freezed,
    Object? gig = freezed,
    Object? musician = freezed,
    Object? status = null,
    Object? coverLetter = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ApplicationModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      gigId: freezed == gigId
          ? _value.gigId
          : gigId // ignore: cast_nullable_to_non_nullable
              as String?,
      musicianId: freezed == musicianId
          ? _value.musicianId
          : musicianId // ignore: cast_nullable_to_non_nullable
              as String?,
      gig: freezed == gig
          ? _value.gig
          : gig // ignore: cast_nullable_to_non_nullable
              as GigModel?,
      musician: freezed == musician
          ? _value.musician
          : musician // ignore: cast_nullable_to_non_nullable
              as AuthApiModel?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      coverLetter: null == coverLetter
          ? _value.coverLetter
          : coverLetter // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApplicationModelImpl implements _ApplicationModel {
  const _$ApplicationModelImpl(
      {@JsonKey(name: '_id', readValue: _readId) this.id,
      this.gigId,
      this.musicianId,
      this.gig,
      this.musician,
      this.status = 'pending',
      this.coverLetter = '',
      this.createdAt});

  factory _$ApplicationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApplicationModelImplFromJson(json);

  @override
  @JsonKey(name: '_id', readValue: _readId)
  final String? id;
  @override
  final String? gigId;
  @override
  final String? musicianId;
  @override
  final GigModel? gig;
  @override
  final AuthApiModel? musician;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String coverLetter;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ApplicationModel(id: $id, gigId: $gigId, musicianId: $musicianId, gig: $gig, musician: $musician, status: $status, coverLetter: $coverLetter, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApplicationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gigId, gigId) || other.gigId == gigId) &&
            (identical(other.musicianId, musicianId) ||
                other.musicianId == musicianId) &&
            (identical(other.gig, gig) || other.gig == gig) &&
            (identical(other.musician, musician) ||
                other.musician == musician) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.coverLetter, coverLetter) ||
                other.coverLetter == coverLetter) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, gigId, musicianId, gig,
      musician, status, coverLetter, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApplicationModelImplCopyWith<_$ApplicationModelImpl> get copyWith =>
      __$$ApplicationModelImplCopyWithImpl<_$ApplicationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApplicationModelImplToJson(
      this,
    );
  }
}

abstract class _ApplicationModel implements ApplicationModel {
  const factory _ApplicationModel(
      {@JsonKey(name: '_id', readValue: _readId) final String? id,
      final String? gigId,
      final String? musicianId,
      final GigModel? gig,
      final AuthApiModel? musician,
      final String status,
      final String coverLetter,
      final DateTime? createdAt}) = _$ApplicationModelImpl;

  factory _ApplicationModel.fromJson(Map<String, dynamic> json) =
      _$ApplicationModelImpl.fromJson;

  @override
  @JsonKey(name: '_id', readValue: _readId)
  String? get id;
  @override
  String? get gigId;
  @override
  String? get musicianId;
  @override
  GigModel? get gig;
  @override
  AuthApiModel? get musician;
  @override
  String get status;
  @override
  String get coverLetter;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ApplicationModelImplCopyWith<_$ApplicationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
