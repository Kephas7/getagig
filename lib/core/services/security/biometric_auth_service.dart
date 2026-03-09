import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

class BiometricAuthService {
  final LocalAuthentication _localAuth;

  BiometricAuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> isBiometricSupported() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!supported || !canCheckBiometrics) {
        return false;
      }

      final available = await _localAuth.getAvailableBiometrics();
      return available.contains(BiometricType.face) ||
          available.contains(BiometricType.fingerprint) ||
          available.contains(BiometricType.strong) ||
          available.contains(BiometricType.weak);
    } catch (_) {
      return false;
    }
  }

  Future<bool> isFingerprintSupported() async {
    return isBiometricSupported();
  }

  Future<bool> authenticateForLogin() async {
    try {
      return await _localAuth.authenticate(
        localizedReason:
            'Authenticate with face unlock or fingerprint to log in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: false,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
