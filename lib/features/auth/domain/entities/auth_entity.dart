import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String? password;

  AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    this.password,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [userId, name, email, password];
}
