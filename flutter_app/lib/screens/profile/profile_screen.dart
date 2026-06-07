import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authProvider).user;
    final parts = (u?.name ?? '').trim().split(' ');
    _firstName = TextEditingController(text: parts.first);
    _lastName = TextEditingController(
        text: parts.length > 1 ? parts.sublist(1).join(' ') : '');
    _email = TextEditingController(text: u?.email ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final fullName =
          '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();
      final data = <String, dynamic>{
        'name': fullName,
        'email': _email.text.trim(),
      };
      final updated =
          await ref.read(userRepositoryProvider).updateProfile(data);
      ref.read(authProvider.notifier).setUser(updated);
      if (!mounted) return;
      _showSnack('Profile updated successfully', success: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showChangePasswordDialog() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool loading = false;
    bool showOld = false;
    bool showNew = false;
    bool showConfirm = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Change Password',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.darkNavy)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Form(
              key: dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _passField('Current Password', oldPass, showOld,
                      () => setLocal(() => showOld = !showOld)),
                  const SizedBox(height: 14),
                  _passField('New Password', newPass, showNew,
                      () => setLocal(() => showNew = !showNew),
                      validator: Validators.password),
                  const SizedBox(height: 14),
                  _passField('Confirm New Password', confirmPass, showConfirm,
                      () => setLocal(() => showConfirm = !showConfirm),
                      validator: (v) =>
                          v != newPass.text ? 'Passwords do not match' : null),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.mutedText))),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: loading
                  ? null
                  : () async {
                      if (!dialogFormKey.currentState!.validate()) return;
                      setLocal(() => loading = true);
                      try {
                        await ref
                            .read(userRepositoryProvider)
                            .updateProfile({'password': newPass.text});
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showSnack('Password changed successfully',
                            success: true);
                      } catch (e) {
                        if (ctx.mounted) {
                          setLocal(() => loading = false);
                          _showSnack(e.toString());
                        }
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passField(String label, TextEditingController ctrl, bool show,
      VoidCallback onToggle,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: !show,
      validator: validator ??
          (v) => (v == null || v.isEmpty) ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
        suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(show ? Icons.visibility_off : Icons.visibility,
                size: 20, color: AppColors.mutedText)),
      ),
    );
  }

  void _showDeleteDialog() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
        content: const Text(
            'This will permanently delete your account and all data. '
            'This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(userRepositoryProvider).deleteProfile();
      await ref.read(authProvider.notifier).logout();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString());
    }
  }

  void _showEditEmailDialog() {
    final ctrl = TextEditingController(text: _email.text);
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Email',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.darkNavy)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'New Email Address',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF7C3AED), width: 1.5)),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.mutedText))),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: loading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setLocal(() => loading = true);
                      try {
                        final updated = await ref
                            .read(userRepositoryProvider)
                            .updateProfile({'email': ctrl.text.trim()});
                        ref.read(authProvider.notifier).setUser(updated);
                        _email.text = ctrl.text.trim();
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showSnack('Email updated', success: true);
                      } catch (e) {
                        setLocal(() => loading = false);
                        _showSnack(e.toString());
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? AppColors.royalBlue : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.darkNavy),
        title: const Text('My Profile',
            style: TextStyle(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkNavy)),
                  const SizedBox(height: 28),

                  // ── Name & Email card ────────────────────────────
                  _sectionCard(children: [
                    LayoutBuilder(builder: (_, constraints) {
                      final wide = constraints.maxWidth >= 480;
                      final firstName = _labelField('First Name', _firstName,
                          'First name',
                          validator: Validators.name);
                      final lastName =
                          _labelField('Last Name', _lastName, 'Last name');
                      if (wide) {
                        return Row(children: [
                          Expanded(child: firstName),
                          const SizedBox(width: 16),
                          Expanded(child: lastName),
                        ]);
                      }
                      return Column(children: [
                        firstName,
                        const SizedBox(height: 16),
                        lastName,
                      ]);
                    }),
                    const SizedBox(height: 20),

                    // Email row
                    const Text('Email',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.darkNavy)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _email,
                          readOnly: true,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.darkText),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _showEditEmailDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkNavy,
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Edit Email',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    const Text('Used to log in to your account',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.mutedText)),
                  ]),
                  const SizedBox(height: 16),

                  // ── Password card ────────────────────────────────
                  _sectionCard(children: [
                    Row(children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkNavy)),
                            SizedBox(height: 4),
                            Text(
                                'Log in with your password instead of using '
                                'temporary login codes',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.mutedText)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: _showChangePasswordDialog,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.darkNavy,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Change Password',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ]),
                  ]),
                  const SizedBox(height: 28),

                  // ── Action buttons ───────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          final u = ref.read(authProvider).user;
                          final parts =
                              (u?.name ?? '').trim().split(' ');
                          _firstName.text = parts.first;
                          _lastName.text = parts.length > 1
                              ? parts.sublist(1).join(' ')
                              : '';
                          _email.text = u?.email ?? '';
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkNavy,
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Save',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                      ),
                    ],
                  ),

                  // ── Danger zone ──────────────────────────────────
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _showDeleteDialog,
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                    label: const Text('Delete Account',
                        style:
                            TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children),
    );
  }

  Widget _labelField(
    String label,
    TextEditingController ctrl,
    String hint, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.darkNavy)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF7C3AED), width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }
}
