import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../routes/route_names.dart';

// Cloudinary images used inside the modal panels.
const _imgStage =
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727301/WhatsApp_Image_2026-03-26_at_17.06.35_2_fjzvhm.jpg';
const _imgClass =
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg';

/// Show the login modal over the current page with a dimmed backdrop.
void showLoginModal(BuildContext context) => showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      barrierDismissible: true,
      builder: (_) => const _AuthDialog(startWithLogin: true),
    );

/// Show the register modal over the current page with a dimmed backdrop.
void showRegisterModal(BuildContext context) => showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      barrierDismissible: true,
      builder: (_) => const _AuthDialog(startWithLogin: false),
    );

// ---------------------------------------------------------------------------

class _AuthDialog extends ConsumerStatefulWidget {
  final bool startWithLogin;
  const _AuthDialog({required this.startWithLogin});

  @override
  ConsumerState<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends ConsumerState<_AuthDialog> {
  late bool _isLogin;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscurePwd = true;
  bool _agreed = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.startWithLogin;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void toggleObscure() => setState(() => _obscurePwd = !_obscurePwd);
  void setAgreed(bool v) => setState(() => _agreed = v);

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMsg = null;
      _formKey.currentState?.reset();
      _agreed = false;
    });
  }

  Future<void> _submit() async {
    setState(() => _errorMsg = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_isLogin && !_agreed) {
      setState(
          () => _errorMsg = 'Please agree to the Terms & Privacy Policy.');
      return;
    }

    bool ok;
    if (_isLogin) {
      ok = await ref
          .read(authProvider.notifier)
          .login(_email.text.trim(), _password.text);
    } else {
      ok = await ref.read(authProvider.notifier).register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            confirmPassword: _confirm.text,
            role: 'client',
          );
    }

    if (!mounted) return;
    if (ok) {
      // Capture router before pop — dialog context is unmounted after pop.
      final isAdmin = ref.read(authProvider).user?.isAdmin ?? false;
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      if (_isLogin && isAdmin) router.go(Routes.adminDashboard);
    } else {
      final msg = ref.read(authProvider).error ??
          (_isLogin ? 'Login failed.' : 'Registration failed.');
      setState(() => _errorMsg = msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider.select((s) => s.loading));
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 680;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: isMobile ? 20 : 48,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 860,
          maxHeight: isMobile ? double.infinity : 620,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: isMobile
              ? _MobileLayout(state: this, loading: loading)
              : _DesktopLayout(state: this, loading: loading),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop layout — image panel + form panel side by side
// ---------------------------------------------------------------------------

class _DesktopLayout extends StatelessWidget {
  final _AuthDialogState state;
  final bool loading;
  const _DesktopLayout({required this.state, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isLogin = state._isLogin;
    final imagePanelWidget = _ImagePanel(
      imageUrl: isLogin ? _imgClass : _imgStage,
      headline: isLogin ? 'Welcome\nBack!' : "Let's Get\nStarted!",
    );
    final formPanelWidget = _FormPanel(state: state, loading: loading);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: isLogin
            ? [
                Expanded(flex: 5, child: formPanelWidget),
                Expanded(flex: 4, child: imagePanelWidget),
              ]
            : [
                Expanded(flex: 4, child: imagePanelWidget),
                Expanded(flex: 5, child: formPanelWidget),
              ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile layout — image strip on top, form below
// ---------------------------------------------------------------------------

class _MobileLayout extends StatelessWidget {
  final _AuthDialogState state;
  final bool loading;
  const _MobileLayout({required this.state, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isLogin = state._isLogin;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 170,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  isLogin ? _imgClass : _imgStage,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xCC0A1B36), Color(0xDD0A1B36)],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _CloseButton(
                      onClose: () => Navigator.of(context).pop()),
                ),
                Center(
                  child: Text(
                    isLogin ? 'Welcome\nBack!' : "Let's Get\nStarted!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _FormPanel(state: state, loading: loading, isMobile: true),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image panel
// ---------------------------------------------------------------------------

class _ImagePanel extends StatelessWidget {
  final String imageUrl;
  final String headline;
  const _ImagePanel({required this.imageUrl, required this.headline});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          loadingBuilder: (c, child, p) =>
              p == null ? child : const ColoredBox(color: AppColors.darkNavy),
        ),
        // gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xBB0A1B36), Color(0xEE083B7A)],
            ),
          ),
        ),
        // logo icon
        const Positioned(
          top: 20,
          left: 20,
          child: _LogoBadge(),
        ),
        // headline
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Form panel
// ---------------------------------------------------------------------------

class _FormPanel extends StatelessWidget {
  final _AuthDialogState state;
  final bool loading;
  final bool isMobile;
  const _FormPanel(
      {required this.state, required this.loading, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 24 : 36,
        isMobile ? 24 : 30,
        isMobile ? 24 : 36,
        isMobile ? 24 : 28,
      ),
      child: Form(
        key: s._formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s._isLogin ? 'Login' : 'Create Account',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s._isLogin
                            ? 'Please enter your login details to log in.'
                            : 'Fill in the details below to create your account.',
                        style: const TextStyle(
                            color: AppColors.mutedText, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  _CloseButton(onClose: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 18),

            // name (register only)
            if (!s._isLogin) ...[
              _ModalField(
                hint: 'Full Name',
                controller: s._name,
                validator: Validators.name,
              ),
              const SizedBox(height: 10),
            ],

            // email
            _ModalField(
              hint: 'Email Address',
              controller: s._email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 10),

            // password
            _ModalField(
              hint: 'Password',
              controller: s._password,
              obscure: s._obscurePwd,
              validator: Validators.password,
              suffix: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: Icon(
                  s._obscurePwd
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.mutedText,
                ),
                onPressed: state.toggleObscure,
              ),
            ),

            // confirm password (register only)
            if (!s._isLogin) ...[
              const SizedBox(height: 10),
              _ModalField(
                hint: 'Confirm Password',
                controller: s._confirm,
                obscure: s._obscurePwd,
                validator: (v) => Validators.confirm(v, s._password.text),
              ),
              const SizedBox(height: 8),
              // Terms checkbox
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: s._agreed,
                      activeColor: AppColors.royalBlue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: AppColors.mutedText),
                      onChanged: (v) => state.setAgreed(v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree with ',
                        style: TextStyle(
                            fontSize: 11.5, color: AppColors.mutedText),
                        children: [
                          TextSpan(
                            text: 'Terms',
                            style: TextStyle(
                              color: AppColors.royalBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.royalBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // forgot password (login only)
            if (s._isLogin) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push(Routes.forgotPassword);
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.royalBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            // inline error
            if (s._errorMsg != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  s._errorMsg!,
                  style:
                      TextStyle(color: Colors.red.shade700, fontSize: 12.5),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // submit button
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: loading ? null : state._submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.royalBlue.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        s._isLogin ? 'Log In' : 'Create Account',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            letterSpacing: 0.4),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // switch mode
            Center(
              child: GestureDetector(
                onTap: state._switchMode,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.mutedText),
                    children: [
                      TextSpan(
                        text: s._isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                      ),
                      TextSpan(
                        text: s._isLogin ? 'Create account' : 'Log In',
                        style: const TextStyle(
                          color: AppColors.royalBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // OR divider
            Row(
              children: [
                const Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'or continue with',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
                  ),
                ),
                const Expanded(child: Divider(thickness: 1)),
              ],
            ),

            const SizedBox(height: 12),

            // social icons row
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialBtn(
                    label: 'G',
                    color: Color(0xFFDB4437),
                    bgColor: Colors.white),
                SizedBox(width: 12),
                _SocialBtn(
                    label: 'f',
                    color: Color(0xFF1877F2),
                    bgColor: Colors.white),
                SizedBox(width: 12),
                _SocialBtn(
                    icon: Icons.apple,
                    color: Colors.black,
                    bgColor: Colors.white),
                SizedBox(width: 12),
                _SocialBtn(
                    icon: Icons.chat_bubble_outline,
                    color: Color(0xFF1DA1F2),
                    bgColor: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable pieces
// ---------------------------------------------------------------------------

class _ModalField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _ModalField({
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.mutedText, fontSize: 13.5),
        suffixIcon: suffix,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide:
              const BorderSide(color: AppColors.royalBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color color;
  final Color bgColor;
  const _SocialBtn(
      {this.label, this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: color, size: 22)
          : Text(
              label!,
              style: TextStyle(
                  color: color, fontSize: 17, fontWeight: FontWeight.w800),
            ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.school, color: Colors.white, size: 20),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onClose;
  const _CloseButton({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.close, size: 16, color: AppColors.mutedText),
      ),
    );
  }
}
