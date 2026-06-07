import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../routes/route_names.dart';
import '../../widgets/common.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Sri Lanka');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      if (user.phone != null) _phoneCtrl.text = user.phone!;
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _addressCtrl, _cityCtrl, _countryCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      _show('Your cart is empty.', error: true);
      return;
    }

    setState(() => _loading = true);
    final billing = BillingInfo(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
    );

    final orderNotifier = ref.read(orderProvider.notifier);
    final order = await orderNotifier.createOrder(
      courseIds: cart.map((i) => i.course.id).toList(),
      billingInfo: billing,
    );

    if (order == null) {
      setState(() => _loading = false);
      _show(ref.read(orderProvider).error ?? 'Failed to create order.', error: true);
      return;
    }

    // Try Stripe checkout
    final url = await orderNotifier.createStripeSession(order.id);
    setState(() => _loading = false);

    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        ref.read(cartProvider.notifier).clear();
        return;
      }
    }

    // Fallback: go directly to confirmation (demo mode)
    ref.read(cartProvider.notifier).clear();
    if (mounted) context.go('${Routes.orderConfirmation}?orderId=${order.id}');
  }

  void _show(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : AppColors.royalBlue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (ref.read(authProvider).status != AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(Routes.home));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: AppColors.darkNavy, onPressed: () => context.go(Routes.cart)),
        title: const Text('Checkout', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: ContentWrap(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 860;
            final billingForm = _BillingForm(
              formKey: _formKey,
              nameCtrl: _nameCtrl,
              emailCtrl: _emailCtrl,
              phoneCtrl: _phoneCtrl,
              addressCtrl: _addressCtrl,
              cityCtrl: _cityCtrl,
              countryCtrl: _countryCtrl,
            );
            final orderSummary = _CheckoutSummary(
              cart: cart,
              total: cartNotifier.total,
              loading: _loading,
              onPlaceOrder: _placeOrder,
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: billingForm),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: orderSummary),
                ],
              );
            }
            return Column(children: [billingForm, const SizedBox(height: 24), orderSummary]);
          }),
        ),
      ),
    );
  }
}

class _BillingForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl, addressCtrl, cityCtrl, countryCtrl;

  const _BillingForm({
    required this.formKey, required this.nameCtrl, required this.emailCtrl,
    required this.phoneCtrl, required this.addressCtrl, required this.cityCtrl, required this.countryCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Customer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
          const SizedBox(height: 20),
          _field(nameCtrl, 'Full Name', Icons.person_outline,
              validator: (v) => Validators.required(v, label: 'Full Name')),
          const SizedBox(height: 14),
          _field(emailCtrl, 'Email Address', Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email),
          const SizedBox(height: 14),
          _field(phoneCtrl, 'Phone Number', Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.phone),
          const SizedBox(height: 14),
          _field(addressCtrl, 'Address', Icons.location_on_outlined),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _field(cityCtrl, 'City', Icons.location_city_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _field(countryCtrl, 'Country', Icons.flag_outlined,
                validator: (v) => Validators.required(v, label: 'Country'))),
          ]),
        ]),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.mutedText),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          filled: true,
          fillColor: AppColors.lightGray,
        ),
        validator: validator,
      );
}

class _CheckoutSummary extends StatelessWidget {
  final List cart;
  final double total;
  final bool loading;
  final VoidCallback onPlaceOrder;
  const _CheckoutSummary({required this.cart, required this.total, required this.loading, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Order Summary', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
        const SizedBox(height: 16),
        ...cart.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(item.course.title, style: const TextStyle(fontSize: 13, color: AppColors.darkText), maxLines: 2, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Text('Rs. ${item.course.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkNavy)),
          ]),
        )),
        const Divider(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Subtotal', style: TextStyle(color: AppColors.mutedText, fontSize: 14)),
          Text('Rs. ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkNavy)),
        ]),
        const SizedBox(height: 4),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Tax', style: TextStyle(color: AppColors.mutedText, fontSize: 14)),
          Text('Rs. 0.00', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkNavy)),
        ]),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.darkNavy)),
          Text('Rs. ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.royalBlue)),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Icon(Icons.lock_outline, size: 16, color: AppColors.royalBlue),
            SizedBox(width: 8),
            Expanded(child: Text('Secure payment via Stripe', style: TextStyle(fontSize: 12, color: AppColors.mutedText))),
          ]),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: loading ? null : onPlaceOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ]),
    );
  }
}
