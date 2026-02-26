import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  error,
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    AuthEntity? user,
    String? errorMessage,
  }) = _AuthState;
}

