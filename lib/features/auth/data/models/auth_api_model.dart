import 'package:getagig/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String username;
  final String email;
  final String? password;
  final String role;
  final String? token;

  AuthApiModel({
    this.id,
    required this.username,
    this.password,
    required this.role,
    required this.email,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "password": password,
      "role": role,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return AuthApiModel(
      id: json['_id'] ?? json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      token: token,
    );
  }

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
}
