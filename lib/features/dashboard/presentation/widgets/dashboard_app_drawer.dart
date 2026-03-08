import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/theme_viewmodel.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/services/security/biometric_auth_service.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';

class DashboardAppDrawer extends ConsumerStatefulWidget {
  const DashboardAppDrawer({super.key});

  @override
  ConsumerState<DashboardAppDrawer> createState() => _DashboardAppDrawerState();
}

class _DashboardAppDrawerState extends ConsumerState<DashboardAppDrawer> {
  bool _isCheckingBiometricState = true;
  bool _isBiometricSupported = false;
  bool _isBiometricEnabled = false;
  bool _isUpdatingBiometricPreference = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
    _loadRoleProfileForAvatar();
  }

  void _loadRoleProfileForAvatar() {
    final role = ref.read(authViewModelProvider).user?.role.toLowerCase();

    if (role == 'musician') {
      final musicianState = ref.read(musicianProfileViewModelProvider);
      if (musicianState.profile == null &&
          musicianState.status != MusicianProfileStatus.loading) {
        ref.read(musicianProfileViewModelProvider.notifier).getProfile();
      }
      return;
    }

    if (role == 'organizer') {
      final organizerState = ref.read(organizerProfileViewModelProvider);
      if (organizerState.profile == null &&
          organizerState.status != OrganizerProfileStatus.loading) {
        ref.read(organizerProfileViewModelProvider.notifier).getProfile();
      }
    }
  }

  Future<void> _loadBiometricPreference() async {
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

  Future<void> _onThemeChanged(ThemeMode? mode) async {
    if (mode == null) return;
    await ref.read(themeViewModelProvider.notifier).setThemeMode(mode);
    if (!mounted) return;
    _showMessage('Theme updated to ${_themeLabel(mode)} mode.');
  }

  Future<void> _onBiometricToggleChanged(bool value) async {
    if (_isUpdatingBiometricPreference) {
      return;
    }

    final sessionService = ref.read(userSessionServiceProvider);

    setState(() {
      _isUpdatingBiometricPreference = true;
    });

    try {
      if (!value) {
        await sessionService.disableBiometricLogin();
        if (!mounted) return;
        setState(() {
          _isBiometricEnabled = false;
        });
        _showMessage('Biometric login disabled.');
        return;
      }

      if (!_isBiometricSupported) {
        _showMessage(
          'Face unlock or fingerprint is not available on this device.',
        );
        return;
      }

      final biometricAuthService = ref.read(biometricAuthServiceProvider);
      final authenticated = await biometricAuthService.authenticateForLogin();
      if (!authenticated) {
        _showMessage('Biometric verification cancelled or failed.');
        return;
      }

      final cachedCredentials = await sessionService
          .getCachedLoginCredentials();
      if (cachedCredentials == null) {
        _showMessage(
          'Please log in with email and password once before enabling biometric login.',
        );
        return;
      }

      await sessionService.enableBiometricLogin(
        email: cachedCredentials.email,
        password: cachedCredentials.password,
      );

      if (!mounted) return;
      setState(() {
        _isBiometricEnabled = true;
      });
      _showMessage('Biometric login enabled.');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingBiometricPreference = false;
        });
      }
    }
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Color _roleAccent(String? role, ColorScheme colorScheme) {
    switch ((role ?? '').toLowerCase()) {
      case 'musician':
        return colorScheme.secondary;
      case 'organizer':
        return colorScheme.primary;
      case 'admin':
        return Colors.red;
      default:
        return colorScheme.tertiary;
    }
  }

  String _buildInitials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _buildUserAvatar({
    required Color roleAccent,
    required String initials,
    required String? profilePicturePath,
  }) {
    final profilePictureUrl = ApiEndpoints.buildProfilePictureUrl(
      profilePicturePath,
    );
    final imageProvider = profilePictureUrl.isEmpty
        ? null
        : CachedNetworkImageProvider(profilePictureUrl);

    return CircleAvatar(
      radius: 24,
      backgroundColor: roleAccent.withValues(alpha: 0.2),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              initials,
              style: TextStyle(
                color: roleAccent,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            )
          : null,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onLogoutTap() async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) return;
    if (mounted) {
      Navigator.of(context).pop();
    }
    ref.read(authViewModelProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final musicianState = ref.watch(musicianProfileViewModelProvider);
    final organizerState = ref.watch(organizerProfileViewModelProvider);
    final themeMode = ref.watch(themeViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final user = authState.user;
    final roleAccent = _roleAccent(user?.role, colorScheme);
    final initials = _buildInitials(user?.username ?? 'User');
    final roleText = (user?.role ?? 'guest').toUpperCase();
    final role = (user?.role ?? '').toLowerCase();
    final profilePicturePath = role == 'musician'
        ? musicianState.profile?.profilePicture
        : role == 'organizer'
        ? organizerState.profile?.profilePicture
        : null;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surfaceContainerHigh,
                    colorScheme.surfaceContainerLow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildUserAvatar(
                        roleAccent: roleAccent,
                        initials: initials,
                        profilePicturePath: profilePicturePath,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'Dashboard settings',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'Manage app settings',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: roleAccent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        roleText,
                        style: TextStyle(
                          color: roleAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Appearance'),
                subtitle: const Text('Theme preference'),
                shape: const Border(),
                collapsedShape: const Border(),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                children: [
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      _onThemeChanged(selection.first);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Security'),
                subtitle: const Text('Biometric login'),
                shape: const Border(),
                collapsedShape: const Border(),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text(
                      'Use face unlock or fingerprint for quicker sign in on this device.',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SwitchListTile.adaptive(
                    value: _isBiometricEnabled,
                    contentPadding: EdgeInsets.zero,
                    onChanged:
                        (_isCheckingBiometricState ||
                            _isUpdatingBiometricPreference ||
                            (!_isBiometricSupported && !_isBiometricEnabled))
                        ? null
                        : _onBiometricToggleChanged,
                    title: const Text('Use biometric for login'),
                    subtitle: _isCheckingBiometricState
                        ? const Text('Checking biometric availability...')
                        : Text(
                            _isBiometricSupported
                                ? (_isBiometricEnabled
                                      ? 'Enabled on this device.'
                                      : 'Turn on this switch and verify biometric identity.')
                                : 'Face unlock or fingerprint is not available or not enrolled on this device.',
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withValues(alpha: 0.26)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Sign out from this account',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                onTap: _onLogoutTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
