import 'package:equatable/equatable.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_api_model.g.dart';

@HiveType(
  typeId: HiveTableConstant.authApiTypeId,
  adapterName: 'AuthApiModelAdapter',
)
@JsonSerializable()
class AuthApiModel extends Equatable {
  static const Object _unset = Object();

  @HiveField(0)
  @JsonKey(name: '_id')
  final String? id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final String? token;

  const AuthApiModel({
    this.id,
    required this.username,
    required this.email,
    this.password,
    required this.role,
    this.token,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  AuthApiModel copyWith({
    Object? id = _unset,
    String? username,
    String? email,
    Object? password = _unset,
    String? role,
    Object? token = _unset,
  }) {
    return AuthApiModel(
      id: id == _unset ? this.id : id as String?,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password == _unset ? this.password : password as String?,
      role: role ?? this.role,
      token: token == _unset ? this.token : token as String?,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(userId: id, username: username, email: email, role: role);
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.userId,
      username: entity.username,
      email: entity.email,
      password: entity.password,
      role: entity.role,
    );
  }

  @override
  List<Object?> get props => [id, username, email, password, role, token];
}
