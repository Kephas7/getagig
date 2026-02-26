// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gig_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GigModel _$GigModelFromJson(Map<String, dynamic> json) {
  return _GigModel.fromJson(json);
}

/// @nodoc
mixin _$GigModel {
  @JsonKey(name: '_id', readValue: _readId)
  String? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  LocationModel get location => throw _privateConstructorUsedError;
  List<String> get genres => throw _privateConstructorUsedError;
  List<String> get instruments => throw _privateConstructorUsedError;
  double get payRate => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  DateTime? get deadline => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  AuthApiModel? get organizer => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GigModelCopyWith<GigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GigModelCopyWith<$Res> {
  factory $GigModelCopyWith(GigModel value, $Res Function(GigModel) then) =
      _$GigModelCopyWithImpl<$Res, GigModel>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id', readValue: _readId) String? id,
      String title,
      String description,
      LocationModel location,
      List<String> genres,
      List<String> instruments,
      double payRate,
      String eventType,
      DateTime? deadline,
      String status,
      AuthApiModel? organizer,
      DateTime? createdAt,
      DateTime? updatedAt});

  $LocationModelCopyWith<$Res> get location;
  $AuthApiModelCopyWith<$Res>? get organizer;
}

/// @nodoc
class _$GigModelCopyWithImpl<$Res, $Val extends GigModel>
    implements $GigModelCopyWith<$Res> {
  _$GigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = null,
    Object? location = null,
    Object? genres = null,
    Object? instruments = null,
    Object? payRate = null,
    Object? eventType = null,
    Object? deadline = freezed,
    Object? status = null,
    Object? organizer = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      genres: null == genres
          ? _value.genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instruments: null == instruments
          ? _value.instruments
          : instruments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      payRate: null == payRate
          ? _value.payRate
          : payRate // ignore: cast_nullable_to_non_nullable
              as double,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      organizer: freezed == organizer
          ? _value.organizer
          : organizer // ignore: cast_nullable_to_non_nullable
              as AuthApiModel?,
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

  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get location {
    return $LocationModelCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthApiModelCopyWith<$Res>? get organizer {
    if (_value.organizer == null) {
      return null;
    }

    return $AuthApiModelCopyWith<$Res>(_value.organizer!, (value) {
      return _then(_value.copyWith(organizer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GigModelImplCopyWith<$Res>
    implements $GigModelCopyWith<$Res> {
  factory _$$GigModelImplCopyWith(
          _$GigModelImpl value, $Res Function(_$GigModelImpl) then) =
      __$$GigModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id', readValue: _readId) String? id,
      String title,
      String description,
      LocationModel location,
      List<String> genres,
      List<String> instruments,
      double payRate,
      String eventType,
      DateTime? deadline,
      String status,
      AuthApiModel? organizer,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $LocationModelCopyWith<$Res> get location;
  @override
  $AuthApiModelCopyWith<$Res>? get organizer;
}

/// @nodoc
class __$$GigModelImplCopyWithImpl<$Res>
    extends _$GigModelCopyWithImpl<$Res, _$GigModelImpl>
    implements _$$GigModelImplCopyWith<$Res> {
  __$$GigModelImplCopyWithImpl(
      _$GigModelImpl _value, $Res Function(_$GigModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = null,
    Object? location = null,
    Object? genres = null,
    Object? instruments = null,
    Object? payRate = null,
    Object? eventType = null,
    Object? deadline = freezed,
    Object? status = null,
    Object? organizer = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$GigModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      genres: null == genres
          ? _value._genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instruments: null == instruments
          ? _value._instruments
          : instruments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      payRate: null == payRate
          ? _value.payRate
          : payRate // ignore: cast_nullable_to_non_nullable
              as double,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      organizer: freezed == organizer
          ? _value.organizer
          : organizer // ignore: cast_nullable_to_non_nullable
              as AuthApiModel?,
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
class _$GigModelImpl extends _GigModel {
  const _$GigModelImpl(
      {@JsonKey(name: '_id', readValue: _readId) this.id,
      required this.title,
      this.description = '',
      this.location = const LocationModel(),
      final List<String> genres = const [],
      final List<String> instruments = const [],
      this.payRate = 0.0,
      this.eventType = '',
      this.deadline,
      this.status = 'open',
      this.organizer,
      this.createdAt,
      this.updatedAt})
      : _genres = genres,
        _instruments = instruments,
        super._();

  factory _$GigModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GigModelImplFromJson(json);

  @override
  @JsonKey(name: '_id', readValue: _readId)
  final String? id;
  @override
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final LocationModel location;
  final List<String> _genres;
  @override
  @JsonKey()
  List<String> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  final List<String> _instruments;
  @override
  @JsonKey()
  List<String> get instruments {
    if (_instruments is EqualUnmodifiableListView) return _instruments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instruments);
  }

  @override
  @JsonKey()
  final double payRate;
  @override
  @JsonKey()
  final String eventType;
  @override
  final DateTime? deadline;
  @override
  @JsonKey()
  final String status;
  @override
  final AuthApiModel? organizer;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'GigModel(id: $id, title: $title, description: $description, location: $location, genres: $genres, instruments: $instruments, payRate: $payRate, eventType: $eventType, deadline: $deadline, status: $status, organizer: $organizer, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GigModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            const DeepCollectionEquality()
                .equals(other._instruments, _instruments) &&
            (identical(other.payRate, payRate) || other.payRate == payRate) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.organizer, organizer) ||
                other.organizer == organizer) &&
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
      title,
      description,
      location,
      const DeepCollectionEquality().hash(_genres),
      const DeepCollectionEquality().hash(_instruments),
      payRate,
      eventType,
      deadline,
      status,
      organizer,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GigModelImplCopyWith<_$GigModelImpl> get copyWith =>
      __$$GigModelImplCopyWithImpl<_$GigModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GigModelImplToJson(
      this,
    );
  }
}

abstract class _GigModel extends GigModel {
  const factory _GigModel(
      {@JsonKey(name: '_id', readValue: _readId) final String? id,
      required final String title,
      final String description,
      final LocationModel location,
      final List<String> genres,
      final List<String> instruments,
      final double payRate,
      final String eventType,
      final DateTime? deadline,
      final String status,
      final AuthApiModel? organizer,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$GigModelImpl;
  const _GigModel._() : super._();

  factory _GigModel.fromJson(Map<String, dynamic> json) =
      _$GigModelImpl.fromJson;

  @override
  @JsonKey(name: '_id', readValue: _readId)
  String? get id;
  @override
  String get title;
  @override
  String get description;
  @override
  LocationModel get location;
  @override
  List<String> get genres;
  @override
  List<String> get instruments;
  @override
  double get payRate;
  @override
  String get eventType;
  @override
  DateTime? get deadline;
  @override
  String get status;
  @override
  AuthApiModel? get organizer;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$GigModelImplCopyWith<_$GigModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
