import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String username;
  final String email;
  final String? password;
  final String role;

  const AuthEntity({
    this.userId,
    required this.username,
    required this.email,
    this.password,
    this.role = 'musician',
  });

  @override
  List<Object?> get props => [userId, username, email, role];
}
