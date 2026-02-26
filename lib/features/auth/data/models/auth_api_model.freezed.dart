// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) {
  return _AuthApiModel.fromJson(json);
}

/// @nodoc
mixin _$AuthApiModel {
  @HiveField(0)
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get username => throw _privateConstructorUsedError;
  @HiveField(2)
  String get email => throw _privateConstructorUsedError;
  @HiveField(3)
  String? get password => throw _privateConstructorUsedError;
  @HiveField(4)
  String get role => throw _privateConstructorUsedError;
  @HiveField(5)
  String? get token => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthApiModelCopyWith<AuthApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthApiModelCopyWith<$Res> {
  factory $AuthApiModelCopyWith(
          AuthApiModel value, $Res Function(AuthApiModel) then) =
      _$AuthApiModelCopyWithImpl<$Res, AuthApiModel>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id') String? id,
      @HiveField(1) String username,
      @HiveField(2) String email,
      @HiveField(3) String? password,
      @HiveField(4) String role,
      @HiveField(5) String? token});
}

/// @nodoc
class _$AuthApiModelCopyWithImpl<$Res, $Val extends AuthApiModel>
    implements $AuthApiModelCopyWith<$Res> {
  _$AuthApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? username = null,
    Object? email = null,
    Object? password = freezed,
    Object? role = null,
    Object? token = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthApiModelImplCopyWith<$Res>
    implements $AuthApiModelCopyWith<$Res> {
  factory _$$AuthApiModelImplCopyWith(
          _$AuthApiModelImpl value, $Res Function(_$AuthApiModelImpl) then) =
      __$$AuthApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id') String? id,
      @HiveField(1) String username,
      @HiveField(2) String email,
      @HiveField(3) String? password,
      @HiveField(4) String role,
      @HiveField(5) String? token});
}

/// @nodoc
class __$$AuthApiModelImplCopyWithImpl<$Res>
    extends _$AuthApiModelCopyWithImpl<$Res, _$AuthApiModelImpl>
    implements _$$AuthApiModelImplCopyWith<$Res> {
  __$$AuthApiModelImplCopyWithImpl(
      _$AuthApiModelImpl _value, $Res Function(_$AuthApiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? username = null,
    Object? email = null,
    Object? password = freezed,
    Object? role = null,
    Object? token = freezed,
  }) {
    return _then(_$AuthApiModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(
    typeId: HiveTableConstant.authApiTypeId, adapterName: 'AuthApiModelAdapter')
class _$AuthApiModelImpl extends _AuthApiModel {
  const _$AuthApiModelImpl(
      {@HiveField(0) @JsonKey(name: '_id') this.id,
      @HiveField(1) required this.username,
      @HiveField(2) required this.email,
      @HiveField(3) this.password,
      @HiveField(4) required this.role,
      @HiveField(5) this.token})
      : super._();

  factory _$AuthApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthApiModelImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: '_id')
  final String? id;
  @override
  @HiveField(1)
  final String username;
  @override
  @HiveField(2)
  final String email;
  @override
  @HiveField(3)
  final String? password;
  @override
  @HiveField(4)
  final String role;
  @override
  @HiveField(5)
  final String? token;

  @override
  String toString() {
    return 'AuthApiModel(id: $id, username: $username, email: $email, password: $password, role: $role, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthApiModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, username, email, password, role, token);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthApiModelImplCopyWith<_$AuthApiModelImpl> get copyWith =>
      __$$AuthApiModelImplCopyWithImpl<_$AuthApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthApiModelImplToJson(
      this,
    );
  }
}

abstract class _AuthApiModel extends AuthApiModel {
  const factory _AuthApiModel(
      {@HiveField(0) @JsonKey(name: '_id') final String? id,
      @HiveField(1) required final String username,
      @HiveField(2) required final String email,
      @HiveField(3) final String? password,
      @HiveField(4) required final String role,
      @HiveField(5) final String? token}) = _$AuthApiModelImpl;
  const _AuthApiModel._() : super._();

  factory _AuthApiModel.fromJson(Map<String, dynamic> json) =
      _$AuthApiModelImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: '_id')
  String? get id;
  @override
  @HiveField(1)
  String get username;
  @override
  @HiveField(2)
  String get email;
  @override
  @HiveField(3)
  String? get password;
  @override
  @HiveField(4)
  String get role;
  @override
  @HiveField(5)
  String? get token;
  @override
  @JsonKey(ignore: true)
  _$$AuthApiModelImplCopyWith<_$AuthApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
