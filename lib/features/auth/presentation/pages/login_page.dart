import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:getagig/app/routes/route_constants.dart';
import 'package:getagig/app/widgets/app_logo.dart';
import 'package:getagig/core/services/security/biometric_auth_service.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:getagig/features/auth/presentation/state/auth_state.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isCheckingBiometricState = true;
  bool _isBiometricSupported = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricLoginInProgress = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadBiometricState());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  Future<void> _loadBiometricState() async {
    final biometricAuthService = ref.read(biometricAuthServiceProvider);
    final sessionService = ref.read(userSessionServiceProvider);

    final isSupported = await biometricAuthService.isFingerprintSupported();
    final isEnabled = isSupported
        ? await sessionService.isBiometricLoginEnabled()
        : false;

    if (!mounted) return;
    setState(() {
      _isBiometricSupported = isSupported;
      _isBiometricEnabled = isEnabled;
      _isCheckingBiometricState = false;
    });
  }

  Future<void> _handleBiometricLogin() async {
    if (_isBiometricLoginInProgress || _isCheckingBiometricState) {
      return;
    }

    final sessionService = ref.read(userSessionServiceProvider);
    final biometricAuthService = ref.read(biometricAuthServiceProvider);

    final credentials = await sessionService.getBiometricCredentials();
    if (credentials == null) {
      await sessionService.disableBiometricLogin();
      if (!mounted) return;
      setState(() {
        _isBiometricEnabled = false;
      });
      _showSnackBar('Biometric login is not set up yet.');
      return;
    }

    final authenticated = await biometricAuthService.authenticateForLogin();
    if (!authenticated) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isBiometricLoginInProgress = true;
    });

    _emailController.text = credentials.email;
    _passwordController.text = credentials.password;

    await ref
        .read(authViewModelProvider.notifier)
        .login(email: credentials.email, password: credentials.password);

    if (!mounted) return;
    setState(() {
      _isBiometricLoginInProgress = false;
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToSignup() {
    context.pushNamed(RouteNames.signup);
  }

  void _navigateToForgotPassword() {
    context.pushNamed(RouteNames.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        if (mounted && _isBiometricLoginInProgress) {
          setState(() {
            _isBiometricLoginInProgress = false;
          });
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isLoading =
        authState.status == AuthStatus.loading || _isBiometricLoginInProgress;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: isLandscape ? 20 : 0),
                    AppLogo(height: isLandscape ? 90 : 150),
                    SizedBox(height: isLandscape ? 12 : 25),
                    Text(
                      "WELCOME",
                      style: TextStyle(
                        fontSize: 27,
                        letterSpacing: 3,
                        color: colorScheme.onSurface.withValues(alpha: 0.78),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 18 : 30),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        final emailRegex = RegExp(
                          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: isLandscape ? 18 : 30),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? CircularProgressIndicator(
                            color: colorScheme.secondary,
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text("Log in"),
                            ),
                          ),
                    if (!_isCheckingBiometricState &&
                        _isBiometricSupported &&
                        _isBiometricEnabled) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _handleBiometricLogin,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Log in with Biometrics'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _navigateToSignup,
                      child: const Text("Create Account"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
