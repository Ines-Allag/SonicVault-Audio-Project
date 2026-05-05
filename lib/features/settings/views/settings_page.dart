import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonic_vault/features/settings/viewmodels/settings_viewmodel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final viewModel = context.read<SettingsViewModel>();
      await viewModel.loadUser();
      if (mounted && viewModel.user != null) {
        _firstNameController.text = viewModel.user!.firstName;
        _lastNameController.text = viewModel.user!.lastName;
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D0D0D),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (_isEditing)
                TextButton(
                  onPressed: viewModel.isSaving
                      ? null
                      : () async {
                    final bool success =
                    await viewModel.updateUserInfo(
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                    );
                    if (success && mounted) {
                      setState(() => _isEditing = false);
                    }
                  },
                  child: viewModel.isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Color(0xFF22c55e),
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF22c55e),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF22c55e),
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── SUCCESS / ERROR MESSAGES ─────────
                if (viewModel.successMessage != null)
                  _buildBanner(
                    message: viewModel.successMessage!,
                    isError: false,
                    onDismiss: viewModel.clearMessages,
                  ),

                if (viewModel.errorMessage != null)
                  _buildBanner(
                    message: viewModel.errorMessage!,
                    isError: true,
                    onDismiss: viewModel.clearMessages,
                  ),

                // ── PROFILE AVATAR ───────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF22c55e)
                              .withOpacity(0.15),
                          border: Border.all(
                            color: const Color(0xFF22c55e),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            viewModel.user != null
                                ? '${viewModel.user!.firstName[0]}${viewModel.user!.lastName[0]}'
                                .toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Color(0xFF22c55e),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        viewModel.user?.fullName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.user?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── SECTION: PROFILE ─────────────────
                _sectionLabel('Profile'),
                const SizedBox(height: 12),

                _buildCard(
                  children: [
                    // first name
                    _buildField(
                      label: 'First Name',
                      controller: _firstNameController,
                      isEditing: _isEditing,
                      icon: Icons.person_outline,
                    ),

                    _divider(),

                    // last name
                    _buildField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      isEditing: _isEditing,
                      icon: Icons.person_outline,
                    ),

                    _divider(),

                    // email — always read only
                    _buildReadOnlyField(
                      label: 'Email',
                      value: viewModel.user?.email ?? '',
                      icon: Icons.email_outlined,
                    ),

                    _divider(),

                    // date of birth — always read only
                    _buildReadOnlyField(
                      label: 'Date of Birth',
                      value: viewModel.user != null
                          ? '${viewModel.user!.birthDate.day}/${viewModel.user!.birthDate.month}/${viewModel.user!.birthDate.year}'
                          : '',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),

                // edit / cancel button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                        if (!_isEditing &&
                            viewModel.user != null) {
                          // cancel → reset fields
                          _firstNameController.text =
                              viewModel.user!.firstName;
                          _lastNameController.text =
                              viewModel.user!.lastName;
                        }
                      });
                      viewModel.clearMessages();
                    },
                    icon: Icon(
                      _isEditing ? Icons.close : Icons.edit,
                      size: 16,
                      color: _isEditing
                          ? Colors.redAccent
                          : const Color(0xFF22c55e),
                    ),
                    label: Text(
                      _isEditing ? 'Cancel' : 'Edit Profile',
                      style: TextStyle(
                        color: _isEditing
                            ? Colors.redAccent
                            : const Color(0xFF22c55e),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── SECTION: ACCOUNT ─────────────────
                _sectionLabel('Account'),
                const SizedBox(height: 12),

                _buildCard(
                  children: [
                    // change password
                    _buildActionRow(
                      icon: Icons.lock_reset_rounded,
                      label: 'Change Password',
                      sublabel: 'Send reset link to your email',
                      iconColor: const Color(0xFF22c55e),
                      onTap: () async {
                        final bool success =
                        await viewModel.sendPasswordReset();
                        if (success && mounted) {
                          _showSnackbar(
                            context,
                            'Reset email sent! Check your inbox.',
                            isError: false,
                          );
                        }
                      },
                    ),

                    _divider(),

                    // logout
                    _buildActionRow(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      sublabel: 'Sign out of your account',
                      iconColor: Colors.redAccent,
                      onTap: () => _showLogoutDialog(
                          context, viewModel),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── SECTION: ABOUT ───────────────────
                _sectionLabel('About'),
                const SizedBox(height: 12),

                _buildCard(
                  children: [
                    _buildInfoRow(
                      icon: Icons.music_note_rounded,
                      label: 'App',
                      value: 'Sonic Vault',
                    ),
                    _divider(),
                    _buildInfoRow(
                      icon: Icons.info_outline,
                      label: 'Version',
                      value: '1.0.0',
                    ),
                    _divider(),
                    _buildInfoRow(
                      icon: Icons.school_outlined,
                      label: 'Course',
                      value: 'ING 3 SEC — Mobile Dev',
                    ),
                    _divider(),
                    _buildInfoRow(
                      icon: Icons.location_city_outlined,
                      label: 'University',
                      value: 'USTHB 2025/2026',
                    ),
                    _divider(),
                    _buildInfoRow(
                      icon: Icons.people_outline,
                      label: 'Team',
                      value: 'Your names here',
                    ),
                  ],
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── LOGOUT DIALOG ─────────────────────────────
  void _showLogoutDialog(
      BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth',
                      (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SNACKBAR ──────────────────────────────────
  void _showSnackbar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.redAccent : const Color(0xFF22c55e),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ── WIDGETS ───────────────────────────────────

  Widget _buildBanner({
    required String message,
    required bool isError,
    required VoidCallback onDismiss,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withOpacity(0.08)
            : const Color(0xFF22c55e).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? Colors.red.withOpacity(0.3)
              : const Color(0xFF22c55e).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color:
            isError ? Colors.redAccent : const Color(0xFF22c55e),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? Colors.redAccent
                    : const Color(0xFF22c55e),
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              color: isError
                  ? Colors.redAccent
                  : const Color(0xFF22c55e),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF22c55e),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                isEditing
                    ? TextFormField(
                  controller: controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 4),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFF22c55e)
                            .withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF22c55e),
                      ),
                    ),
                  ),
                )
                    : Text(
                  controller.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (isEditing)
            const Icon(
              Icons.edit,
              color: Color(0xFF22c55e),
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.lock_outline,
            color: Colors.white24,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 16,
      endIndent: 16,
    );
  }
}