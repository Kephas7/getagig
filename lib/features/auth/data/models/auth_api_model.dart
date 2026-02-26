import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';

part 'auth_api_model.freezed.dart';
part 'auth_api_model.g.dart';

@freezed
class AuthApiModel with _$AuthApiModel {
  @HiveType(typeId: HiveTableConstant.authApiTypeId, adapterName: 'AuthApiModelAdapter')
  const factory AuthApiModel({
    @HiveField(0) @JsonKey(name: '_id') String? id,
    @HiveField(1) required String username,
    @HiveField(2) required String email,
    @HiveField(3) String? password,
    @HiveField(4) required String role,
    @HiveField(5) String? token,
  }) = _AuthApiModel;

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  const AuthApiModel._();

  AuthEntity toEntity() {
    return AuthEntity(
      userId: id,
      username: username,
      email: email,
      role: role,
    );
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
}

