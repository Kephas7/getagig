import 'package:getagig/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String username;
  final String email;
  final String? password;
  final String role;

  AuthApiModel({
    this.id,
    required this.username,
    this.password,
    required this.role,
    required this.email,
  });

  //toJson
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "password": password,
      "role": role,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(userId: id, username: username, email: email, role: role);
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      username: entity.username,
      email: entity.email,
      password: entity.password,
      role: entity.role,
    );
  }
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
