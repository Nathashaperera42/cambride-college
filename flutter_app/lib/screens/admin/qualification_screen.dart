import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_theme.dart';
import '../../models/qualification_model.dart';
import '../../providers/qualification_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);
const _kMainBg = Color(0xFFF4F5FA);

class QualificationScreen extends ConsumerStatefulWidget {
  const QualificationScreen({super.key});

  @override
  ConsumerState<QualificationScreen> createState() => _QualificationScreenState();
}

class _QualificationScreenState extends ConsumerState<QualificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qualificationProvider.notifier).loadAdminAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qualificationProvider);

    return AdminShell(
      activeRoute: Routes.adminQualifications,
      breadcrumbs: const ['Admin', 'Cambridge Qualifications'],
      body: Scaffold(
        backgroundColor: _kMainBg,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Qualification', style: TextStyle(fontWeight: FontWeight.w600)),
          onPressed: () => _showUpsertDialog(context, ref, null),
        ),
        body: state.loading
            ? const Center(child: CircularProgressIndicator())
            : state.qualifications.isEmpty
                ? const Center(
                    child: Text('No qualifications yet. Use the + button to add one.',
                        style: TextStyle(color: _kMutedColor)),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: LayoutBuilder(builder: (_, constraints) {
                      final cols = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
                      const gap = 16.0;
                      final cardW = (constraints.maxWidth - gap * (cols - 1)) / cols;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: state.qualifications
                            .map((q) => _QualificationCard(
                                  qualification: q,
                                  width: cardW,
                                  onEdit: () => _showUpsertDialog(context, ref, q),
                                  onDelete: () => _confirmDelete(context, ref, q),
                                  onToggle: (val) => ref.read(qualificationProvider.notifier).update(
                                        q.id,
                                        title: q.title,
                                        description: q.description,
                                        features: q.features,
                                        gold: q.gold,
                                        redirectUrl: q.redirectUrl,
                                        order: q.order,
                                        isActive: val,
                                      ),
                                ))
                            .toList(),
                      );
                    }),
                  ),
      ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref, QualificationModel q) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Delete Qualification', style: TextStyle(fontWeight: FontWeight.w700, color: _kTitleColor)),
      content: Text('Delete "${q.title}"? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final success = await ref.read(qualificationProvider.notifier).delete(q.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Qualification deleted' : 'Delete failed'),
      backgroundColor: success ? AppColors.royalBlue : Colors.red,
    ));
  }
}

class _QualificationCard extends StatelessWidget {
  final QualificationModel qualification;
  final double width;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _QualificationCard({
    required this.qualification,
    required this.width,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  qualification.image != null
                      ? CachedNetworkImage(
                          imageUrl: qualification.image!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _gradientFallback(),
                        )
                      : _gradientFallback(),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: qualification.isActive ? const Color(0xFF22C55E) : _kMutedColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(qualification.isActive ? 'Active' : 'Hidden',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(qualification.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kTitleColor)),
                  const SizedBox(height: 4),
                  Text(qualification.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _kMutedColor, height: 1.4)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        alignment: Alignment.centerLeft,
                        child: Switch(value: qualification.isActive, activeThumbColor: _kPrimary, onChanged: onToggle),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: _kPrimary),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientFallback() => Container(
        decoration: BoxDecoration(gradient: qualification.gold ? AppColors.goldCardGradient : AppColors.blueCardGradient),
        alignment: Alignment.center,
        child: Icon(qualification.gold ? Icons.emoji_events_outlined : Icons.school_outlined,
            color: Colors.white.withValues(alpha: 0.9), size: 36),
      );
}

Future<void> _showUpsertDialog(BuildContext context, WidgetRef ref, QualificationModel? existing) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final featuresCtrl = TextEditingController(text: existing?.features.join('\n') ?? '');
  final redirectCtrl = TextEditingController(text: existing?.redirectUrl ?? '');
  final orderCtrl = TextEditingController(text: existing?.order.toString() ?? '0');
  bool gold = existing?.gold ?? false;
  bool isActive = existing?.isActive ?? true;
  Uint8List? pickedBytes;
  String? pickedName;
  String? previewUrl = existing?.image;
  bool loading = false;
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'Add Qualification' : 'Edit Qualification',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kTitleColor),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final xfile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1400, imageQuality: 90);
                      if (xfile == null) return;
                      final bytes = await xfile.readAsBytes();
                      setLocal(() {
                        pickedBytes = bytes;
                        pickedName = xfile.name;
                        previewUrl = null;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: _kMainBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorderColor, width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: pickedBytes != null
                          ? Image.memory(pickedBytes!, fit: BoxFit.cover)
                          : previewUrl != null
                              ? CachedNetworkImage(imageUrl: previewUrl!, fit: BoxFit.cover)
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, size: 38, color: _kMutedColor),
                                    SizedBox(height: 8),
                                    Text('Click to choose a card image (optional)',
                                        style: TextStyle(fontSize: 12, color: _kMutedColor)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: _inputDeco('Title *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: _inputDeco('Description *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: featuresCtrl,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: _inputDeco('Features (one per line)'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: redirectCtrl,
                    decoration: _inputDeco('Learn-more URL (optional)'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Display order'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text('Gold card style', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _kTitleColor)),
                      const Spacer(),
                      Switch(value: gold, activeThumbColor: _kPrimary, onChanged: (v) => setLocal(() => gold = v)),
                    ],
                  ),
                  if (existing != null)
                    Row(
                      children: [
                        const Text('Active', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _kTitleColor)),
                        const Spacer(),
                        Switch(value: isActive, activeThumbColor: _kPrimary, onChanged: (v) => setLocal(() => isActive = v)),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: loading ? null : () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: _kMutedColor)),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _kPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: loading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setLocal(() => loading = true);
                                final features = featuresCtrl.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                                bool ok;
                                if (existing == null) {
                                  ok = await ref.read(qualificationProvider.notifier).create(
                                        title: titleCtrl.text.trim(),
                                        description: descCtrl.text.trim(),
                                        features: features,
                                        gold: gold,
                                        redirectUrl: redirectCtrl.text.trim().isEmpty ? null : redirectCtrl.text.trim(),
                                        order: int.tryParse(orderCtrl.text) ?? 0,
                                        imageBytes: pickedBytes,
                                        fileName: pickedName,
                                      );
                                } else {
                                  ok = await ref.read(qualificationProvider.notifier).update(
                                        existing.id,
                                        title: titleCtrl.text.trim(),
                                        description: descCtrl.text.trim(),
                                        features: features,
                                        gold: gold,
                                        redirectUrl: redirectCtrl.text.trim().isEmpty ? null : redirectCtrl.text.trim(),
                                        order: int.tryParse(orderCtrl.text) ?? 0,
                                        isActive: isActive,
                                        imageBytes: pickedBytes,
                                        fileName: pickedName,
                                      );
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(ok ? (existing == null ? 'Qualification added' : 'Qualification updated') : 'Something went wrong'),
                                    backgroundColor: ok ? AppColors.royalBlue : Colors.red,
                                  ));
                                }
                              },
                        child: loading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(existing == null ? 'Create' : 'Save', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  titleCtrl.dispose();
  descCtrl.dispose();
  featuresCtrl.dispose();
  redirectCtrl.dispose();
  orderCtrl.dispose();
}

InputDecoration _inputDeco(String label) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
