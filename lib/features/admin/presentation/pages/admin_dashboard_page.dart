import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/presentation/view_model/admin_users_viewmodel.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/musician/presentation/pages/view_profile_page.dart';
import 'package:getagig/features/organizer/presentation/pages/view_organizer_profile_page.dart';
import 'package:intl/intl.dart';

enum _AdminUserFilter { all, musician, organizer, pending }

class _AdminMetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminMetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  _AdminUserFilter _selectedFilter = _AdminUserFilter.all;
  String? _busyUserId;
  bool _isCreatingUser = false;
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Control Center',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Users, roles and verification',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          _buildAppBarAction(
            icon: Icons.person_add_alt_1_rounded,
            tooltip: 'Create user',
            onPressed: _isCreatingUser ? null : _onCreateUser,
            replacementIcon: _isCreatingUser
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          _buildAppBarAction(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            onPressed: () => ref.read(adminUsersProvider.notifier).refresh(),
          ),
          _buildAppBarAction(
            icon: Icons.logout_rounded,
            tooltip: 'Logout',
            onPressed: _isLoggingOut ? null : _onLogout,
            replacementIcon: _isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecoratedBox(
        decoration: AppShellStyles.pageBackground(context),
        child: usersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (users) => _buildContent(users),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Widget? replacementIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: replacementIcon ?? Icon(icon),
          color: colorScheme.onSurface,
          iconSize: 20,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: AppShellStyles.glassCard(context, radius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Unable to load users',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(adminUsersProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(List<AdminUserEntity> users) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredUsers = _filterUsers(users);
    final musicianCount = users
        .where((user) => user.role.toLowerCase() == 'musician')
        .length;
    final organizerCount = users
        .where((user) => user.role.toLowerCase() == 'organizer')
        .length;
    final pendingCount = users
        .where(
          (user) =>
              user.isVerifiableRole &&
              !user.isVerified &&
              user.verificationRequested,
        )
        .length;
    final verifiedCount = users
        .where((user) => user.isVerifiableRole && user.isVerified)
        .length;

    return RefreshIndicator(
      onRefresh: () => ref.read(adminUsersProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _buildOverviewCard(
            totalUsers: users.length,
            musicianCount: musicianCount,
            organizerCount: organizerCount,
            pendingCount: pendingCount,
            verifiedCount: verifiedCount,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: AppShellStyles.glassCard(context, radius: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filter Users',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredUsers.length}/${users.length}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFilterChips(users),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (filteredUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppShellStyles.glassCard(context, radius: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 40,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No users found for this filter.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filteredUsers.map(_buildUserCard),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required int totalUsers,
    required int musicianCount,
    required int organizerCount,
    required int pendingCount,
    required int verifiedCount,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardItems = [
      _AdminMetricData(
        label: 'Total Users',
        value: '$totalUsers',
        icon: Icons.groups_rounded,
        color: colorScheme.secondary,
      ),
      _AdminMetricData(
        label: 'Musicians',
        value: '$musicianCount',
        icon: Icons.music_note_rounded,
        color: const Color(0xFF4F8CFF),
      ),
      _AdminMetricData(
        label: 'Organizers',
        value: '$organizerCount',
        icon: Icons.business_center_rounded,
        color: const Color(0xFF10B981),
      ),
      _AdminMetricData(
        label: 'Pending Reviews',
        value: '$pendingCount',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _AdminMetricData(
        label: 'Verified',
        value: '$verifiedCount',
        icon: Icons.verified_rounded,
        color: const Color(0xFF10B981),
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: AppShellStyles.glassCard(
        context,
        radius: 24,
        tint: colorScheme.secondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Snapshot',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quick overview of account and verification health',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 560 ? 5 : 2;
              final spacing = 10.0;
              final itemWidth =
                  (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                  crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cardItems
                    .map(
                      (item) => _buildMetricTile(item: item, width: itemWidth),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required _AdminMetricData item,
    required double width,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: item.color.withValues(
            alpha: AppShellStyles.isDark(context) ? 0.2 : 0.1,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, size: 17, color: item.color),
            const SizedBox(height: 8),
            Text(
              item.value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<AdminUserEntity> users) {
    final musicianCount = users
        .where((user) => user.role.toLowerCase() == 'musician')
        .length;
    final organizerCount = users
        .where((user) => user.role.toLowerCase() == 'organizer')
        .length;
    final pendingCount = users
        .where(
          (user) =>
              user.isVerifiableRole &&
              !user.isVerified &&
              user.verificationRequested,
        )
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All (${users.length})',
            filter: _AdminUserFilter.all,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Musicians ($musicianCount)',
            filter: _AdminUserFilter.musician,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Organizers ($organizerCount)',
            filter: _AdminUserFilter.organizer,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Pending ($pendingCount)',
            filter: _AdminUserFilter.pending,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _AdminUserFilter filter,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _selectedFilter == filter;

    IconData icon;
    switch (filter) {
      case _AdminUserFilter.all:
        icon = Icons.groups_rounded;
        break;
      case _AdminUserFilter.musician:
        icon = Icons.music_note_rounded;
        break;
      case _AdminUserFilter.organizer:
        icon = Icons.business_center_rounded;
        break;
      case _AdminUserFilter.pending:
        icon = Icons.pending_actions_rounded;
        break;
    }

    return ChoiceChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: selected
            ? colorScheme.onSecondaryContainer
            : colorScheme.secondary,
      ),
      selected: selected,
      showCheckmark: false,
      backgroundColor: colorScheme.surfaceContainerLow,
      selectedColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: colorScheme.outlineVariant),
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
    );
  }

  Widget _buildUserCard(AdminUserEntity user) {
    final isBusy = _busyUserId == user.id;
    final avatarUrl = ApiEndpoints.buildProfilePictureUrl(user.profilePicture);
    final colorScheme = Theme.of(context).colorScheme;
    final roleColor = _roleColor(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppShellStyles.glassCard(
        context,
        radius: 20,
        highlighted: isBusy,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: roleColor.withValues(alpha: 0.2),
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          _initialsFromName(user.username),
                          style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Joined ${_formatDate(user.createdAt)}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isBusy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPill(label: user.role.toUpperCase(), color: roleColor),
                if (user.isVerifiableRole)
                  _buildPill(
                    label: _verificationLabel(user),
                    color: _verificationColor(user),
                  ),
                if (_canViewProfile(user))
                  _buildPill(
                    label: 'PROFILE LINKED',
                    color: colorScheme.secondary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_canViewProfile(user))
                  _buildActionButton(
                    label: 'View',
                    icon: Icons.visibility_outlined,
                    onPressed: isBusy ? null : () => _onViewProfile(user),
                    color: colorScheme.secondary,
                  ),
                _buildActionButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onPressed: isBusy ? null : () => _onEditUser(user),
                  color: colorScheme.primary,
                ),
                _buildActionButton(
                  label: 'Delete',
                  icon: Icons.delete_outline,
                  onPressed: isBusy ? null : () => _onDeleteUser(user),
                  color: colorScheme.error,
                ),
              ],
            ),
            if (user.isVerifiableRole) ...[
              const SizedBox(height: 12),
              if (user.isVerified)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User is currently verified.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: isBusy
                            ? null
                            : () => _onVerificationAction(
                                user: user,
                                isVerified: false,
                              ),
                        icon: const Icon(Icons.verified_user_outlined),
                        label: const Text('Mark as unverified'),
                      ),
                    ],
                  ),
                )
              else if (user.verificationRequested)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _onVerificationAction(
                              user: user,
                              isVerified: true,
                            ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve'),
                    ),
                    OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _onDenyVerification(user),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Deny'),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No verification request submitted yet.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onCreateUser() async {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    var selectedRole = 'musician';

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create user'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        validator: (value) {
                          final username = value?.trim() ?? '';
                          if (username.isEmpty) return 'Username is required';
                          if (username.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Email is required';
                          if (!email.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(
                            value: 'musician',
                            child: Text('Musician'),
                          ),
                          DropdownMenuItem(
                            value: 'organizer',
                            child: Text('Organizer'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          final password = value?.trim() ?? '';
                          if (password.isEmpty) return 'Password is required';
                          if (password.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) return;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    if (shouldCreate != true) return;

    setState(() {
      _isCreatingUser = true;
    });

    final errorMessage = await ref
        .read(adminUsersProvider.notifier)
        .createUser(
          username: username,
          email: email,
          password: password,
          role: selectedRole,
        );

    if (!mounted) return;

    setState(() {
      _isCreatingUser = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'User created successfully'),
        backgroundColor: errorMessage == null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    await ref.read(authViewModelProvider.notifier).logout();

    if (!mounted) return;

    setState(() {
      _isLoggingOut = false;
    });
  }

  Future<void> _onVerificationAction({
    required AdminUserEntity user,
    required bool isVerified,
    String? rejectionReason,
  }) async {
    setState(() {
      _busyUserId = user.id;
    });

    final errorMessage = await ref
        .read(adminUsersProvider.notifier)
        .setVerificationStatus(
          user: user,
          isVerified: isVerified,
          rejectionReason: rejectionReason,
        );

    if (!mounted) return;

    setState(() {
      _busyUserId = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          errorMessage ??
              (isVerified
                  ? 'Verification approved successfully'
                  : rejectionReason != null
                  ? 'Verification denied successfully'
                  : 'User marked as unverified'),
        ),
        backgroundColor: errorMessage == null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _onDenyVerification(AdminUserEntity user) async {
    final reason = await _showDenyReasonDialog();
    if (!mounted || reason == null) return;

    if (reason.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rejection reason is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _onVerificationAction(
      user: user,
      isVerified: false,
      rejectionReason: reason,
    );
  }

  void _onViewProfile(AdminUserEntity user) {
    final profileId = user.profileId?.trim();
    if (profileId == null || profileId.isEmpty) return;

    final role = user.role.toLowerCase();
    if (role == 'musician') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewProfilePage(musicianId: profileId),
        ),
      );
      return;
    }

    if (role == 'organizer') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewOrganizerProfilePage(organizerId: profileId),
        ),
      );
    }
  }

  Future<void> _onEditUser(AdminUserEntity user) async {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    var selectedRole = user.role.toLowerCase();

    if (!['admin', 'musician', 'organizer'].contains(selectedRole)) {
      selectedRole = 'musician';
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit user'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Email is required';
                          if (!email.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(
                            value: 'musician',
                            child: Text('Musician'),
                          ),
                          DropdownMenuItem(
                            value: 'organizer',
                            child: Text('Organizer'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'New password (optional)',
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) return;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    if (shouldSave != true) return;

    setState(() {
      _busyUserId = user.id;
    });

    final errorMessage = await ref
        .read(adminUsersProvider.notifier)
        .updateUser(
          userId: user.id,
          username: username,
          email: email,
          role: selectedRole,
          password: password.isEmpty ? null : password,
        );

    if (!mounted) return;

    setState(() {
      _busyUserId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'User updated successfully'),
        backgroundColor: errorMessage == null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _onDeleteUser(AdminUserEntity user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete user'),
          content: Text(
            'Delete ${user.username}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _busyUserId = user.id;
    });

    final errorMessage = await ref
        .read(adminUsersProvider.notifier)
        .deleteUser(user.id);

    if (!mounted) return;

    setState(() {
      _busyUserId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'User deleted successfully'),
        backgroundColor: errorMessage == null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<String?> _showDenyReasonDialog() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deny verification'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return reason;
  }

  List<AdminUserEntity> _filterUsers(List<AdminUserEntity> users) {
    switch (_selectedFilter) {
      case _AdminUserFilter.musician:
        return users
            .where((user) => user.role.toLowerCase() == 'musician')
            .toList();
      case _AdminUserFilter.organizer:
        return users
            .where((user) => user.role.toLowerCase() == 'organizer')
            .toList();
      case _AdminUserFilter.pending:
        return users
            .where(
              (user) =>
                  user.isVerifiableRole &&
                  !user.isVerified &&
                  user.verificationRequested,
            )
            .toList();
      case _AdminUserFilter.all:
        return users;
    }
  }

  bool _canViewProfile(AdminUserEntity user) {
    final role = user.role.toLowerCase();
    final profileId = user.profileId?.trim();
    final hasProfile = profileId != null && profileId.isNotEmpty;

    return hasProfile && (role == 'musician' || role == 'organizer');
  }

  Widget _buildPill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFEF4444);
      case 'organizer':
        return const Color(0xFF10B981);
      case 'musician':
        return const Color(0xFF4F8CFF);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _verificationLabel(AdminUserEntity user) {
    if (user.isVerified) return 'Verified';
    if (user.verificationRequested) return 'Requested';
    return 'Not verified';
  }

  Color _verificationColor(AdminUserEntity user) {
    if (user.isVerified) return const Color(0xFF10B981);
    if (user.verificationRequested) return const Color(0xFFF59E0B);
    return const Color(0xFF94A3B8);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat.yMMMd().format(date);
  }

  String _initialsFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}
