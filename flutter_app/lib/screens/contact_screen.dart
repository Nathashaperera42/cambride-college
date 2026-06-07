import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/validators.dart';
import '../providers/app_providers.dart';
import '../widgets/common.dart';

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  bool _submitting = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final client = ref.read(dioClientProvider);
      final res = await client.dio.post(ApiConstants.contact, data: {
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'subject': _subject.text.trim(),
        'message': _message.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res.data['message'] as String? ?? 'Message sent!'),
          backgroundColor: AppColors.royalBlue,
        ));
        _formKey.currentState?.reset();
        for (final c in [_name, _email, _phone, _subject, _message]) { c.clear(); }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to send. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        const PageBanner(
          title: 'Get In Touch',
          subtitle:
              "We'd love to hear from you. Reach out to us for any inquiries.",
        ),
        Container(
          width: double.infinity,
          color: AppColors.lightBlueBg,
          child: ContentWrap(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: isMobile
                ? Column(
                    children: [
                      _form(context),
                      const SizedBox(height: 32),
                      _info(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _form(context)),
                      const SizedBox(width: 32),
                      Expanded(child: _info()),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send us a Message',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24, color: AppColors.darkNavy)),
            const SizedBox(height: 20),
            _field('Name', _name, 'Your full name'),
            _field('Email', _email, 'your.email@example.com',
                keyboard: TextInputType.emailAddress,
                validator: Validators.email),
            _field('Phone', _phone, '+94 XXX XXX XXX',
                keyboard: TextInputType.phone,
                required: false,
                validator: Validators.phone),
            _field('Subject', _subject, 'What is this about?',
                required: false),
            _field('Message', _message, 'Tell us more about your inquiry...',
                maxLines: 5),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: _submitting ? 'Sending…' : 'Send Message',
                onPressed: _submitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.darkText)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            validator: validator ??
                (required
                    ? (v) => (v == null || v.trim().isEmpty)
                        ? 'This field is required'
                        : null
                    : null),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.lightGray,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.royalBlue, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info() {
    final items = [
      _InfoData(Icons.phone, 'Phone', [AppData.phone1, AppData.phone2]),
      _InfoData(Icons.email_outlined, 'Email', [AppData.email]),
      _InfoData(Icons.location_on_outlined, 'Office Address',
          ['Waslow Waratha,', 'Madampitiya 81220,', 'Sri Lanka']),
      _InfoData(Icons.access_time, 'Office Hours', [
        'Mon - Fri: 8:00 AM - 6:00 PM',
        'Saturday: 9:00 AM - 4:00 PM',
        'Sunday: Closed'
      ]),
    ];

    return Column(
      children: items
          .map((i) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(i.icon, color: AppColors.royalBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: AppColors.darkNavy)),
                          const SizedBox(height: 6),
                          ...i.lines.map((l) => Text(l,
                              style: const TextStyle(
                                  color: AppColors.darkText, height: 1.5))),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _InfoData {
  final IconData icon;
  final String title;
  final List<String> lines;
  _InfoData(this.icon, this.title, this.lines);
}
