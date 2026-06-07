import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_providers.dart';
import '../../routes/route_names.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // If no token was passed, we'll show an error banner
    if (widget.token.isEmpty) {
      _error = 'Invalid or missing reset token. Please request a new link.';
    }
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(dioClientProvider);
      await client.dio.post(ApiConstants.resetPassword, data: {
        'token': widget.token,
        'password': _passCtrl.text,
      });
      setState(() => _success = true);

      // Auto-navigate to login after 3 s
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) context.go(Routes.home);
    } catch (e) {
      setState(() {
        _error = _parseError(e);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('expired') || msg.contains('invalid')) {
      return 'This reset link has expired or is invalid. Please request a new one.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: _success ? _successCard() : _formCard(),
          ),
        ),
      ),
    );
  }

  // ── Success state ────────────────────────────────────────────────────────────

  Widget _successCard() {
    return _Card(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                size: 38, color: Color(0xFF16A34A)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Password Reset!',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.darkNavy),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your password has been updated successfully. '
            'You will be redirected to the home page in a moment.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.mutedText, height: 1.6, fontSize: 14),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go(Routes.home),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.home_outlined, size: 18),
              label: const Text('Go to Home',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form state ───────────────────────────────────────────────────────────────

  Widget _formCard() {
    return _Card(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.royalBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline,
                  size: 32, color: AppColors.royalBlue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Set New Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter a strong new password for your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.mutedText, height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 28),

            // Error banner
            if (_error != null) ...[
              _Banner(message: _error!, isError: true),
              const SizedBox(height: 16),
            ],

            // New password
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              validator: Validators.password,
              decoration: _inputDec(
                'New Password',
                Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  icon: Icon(
                      _obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.mutedText),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Confirm password
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _passCtrl.text) return 'Passwords do not match';
                return null;
              },
              decoration: _inputDec(
                'Confirm New Password',
                Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.mutedText),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Password requirements hint
            const _PasswordHints(),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    (_loading || widget.token.isEmpty) ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Reset Password',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 16),

            // Back to home
            Center(
              child: TextButton.icon(
                onPressed: () => context.go(Routes.home),
                icon: const Icon(Icons.arrow_back,
                    size: 16, color: AppColors.royalBlue),
                label: const Text('Back to Home',
                    style: TextStyle(color: AppColors.royalBlue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon,
      {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.mutedText),
        suffixIcon: suffix,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.royalBlue, width: 1.5)),
        filled: true,
        fillColor: AppColors.lightGray,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [child],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isError;
  const _Banner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final bg = isError ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7);
    final fg =
        isError ? const Color(0xFF991B1B) : const Color(0xFF166534);
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: fg, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _PasswordHints extends StatelessWidget {
  const _PasswordHints();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password must contain:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkNavy)),
          SizedBox(height: 6),
          _Hint('At least 8 characters'),
          _Hint('At least one letter and one number'),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 5, color: AppColors.mutedText),
          const SizedBox(width: 7),
          Text(text,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.mutedText)),
        ],
      ),
    );
  }
}
