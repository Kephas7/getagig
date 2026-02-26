import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? id;
  final String username;
  final String email;
  final String? password;
  final String role;
  final String? token;

  const AuthEntity({
    this.userId,
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.role = 'musician',
    this.token,
  });

  @override
  List<Object?> get props => [userId, id, username, email, role, token];
}
