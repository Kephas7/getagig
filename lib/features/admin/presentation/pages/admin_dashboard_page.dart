import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/presentation/view_model/admin_users_viewmodel.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/musician/presentation/pages/view_profile_page.dart';
import 'package:getagig/features/organizer/presentation/pages/view_organizer_profile_page.dart';
import 'package:intl/intl.dart';

enum _AdminUserFilter { all, musician, organizer, pending }

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isCreatingUser ? null : _onCreateUser,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: 'Create user',
          ),
          IconButton(
            onPressed: _isLoggingOut ? null : _onLogout,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
          IconButton(
            onPressed: () {
              ref.read(adminUsersProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (users) => _buildContent(users),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(adminUsersProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<AdminUserEntity> users) {
    final filteredUsers = _filterUsers(users);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _buildFilterChips(users),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(adminUsersProvider.notifier).refresh(),
            child: filteredUsers.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No users found for this filter.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
          ),
        ),
      ],
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
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == filter,
      selectedColor: Colors.black87,
      labelStyle: TextStyle(
        color: _selectedFilter == filter ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
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
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          _initialsFromName(user.username),
                          style: const TextStyle(
                            color: Colors.black87,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Joined ${_formatDate(user.createdAt)}',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_canViewProfile(user))
                      IconButton(
                        onPressed: isBusy ? null : () => _onViewProfile(user),
                        icon: const Icon(
                          Icons.visibility_outlined,
                          color: Colors.blueGrey,
                        ),
                        tooltip: 'View profile',
                      ),
                    IconButton(
                      onPressed: isBusy ? null : () => _onEditUser(user),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blueAccent,
                      ),
                      tooltip: 'Edit user',
                    ),
                    IconButton(
                      onPressed: isBusy ? null : () => _onDeleteUser(user),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Delete user',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPill(
                  label: user.role.toUpperCase(),
                  color: _roleColor(user.role),
                ),
                if (user.isVerifiableRole)
                  _buildPill(
                    label: _verificationLabel(user),
                    color: _verificationColor(user),
                  ),
              ],
            ),
            if (user.isVerifiableRole) ...[
              const SizedBox(height: 12),
              if (user.isVerified)
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => _onVerificationAction(
                            user: user,
                            isVerified: false,
                          ),
                    icon: const Icon(Icons.verified_user_outlined),
                    label: const Text('Mark as unverified'),
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
                const Text(
                  'No verification request submitted.',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ],
        ),
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
        return Colors.redAccent;
      case 'organizer':
        return Colors.green;
      case 'musician':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  String _verificationLabel(AdminUserEntity user) {
    if (user.isVerified) return 'Verified';
    if (user.verificationRequested) return 'Requested';
    return 'Not verified';
  }

  Color _verificationColor(AdminUserEntity user) {
    if (user.isVerified) return Colors.green;
    if (user.verificationRequested) return Colors.orange;
    return Colors.grey;
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
