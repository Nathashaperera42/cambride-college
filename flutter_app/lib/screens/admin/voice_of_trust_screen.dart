import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_theme.dart';
import '../../models/voice_of_trust_model.dart';
import '../../providers/voice_of_trust_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);
const _kMainBg = Color(0xFFF4F5FA);

class VoiceOfTrustScreen extends ConsumerStatefulWidget {
  const VoiceOfTrustScreen({super.key});

  @override
  ConsumerState<VoiceOfTrustScreen> createState() => _VoiceOfTrustScreenState();
}

class _VoiceOfTrustScreenState extends ConsumerState<VoiceOfTrustScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceOfTrustProvider.notifier).loadAdminAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceOfTrustProvider);

    return AdminShell(
      activeRoute: Routes.adminVoiceOfTrust,
      breadcrumbs: const ['Admin', 'Voice of Trust'],
      body: Scaffold(
        backgroundColor: _kMainBg,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Entry', style: TextStyle(fontWeight: FontWeight.w600)),
          onPressed: () => _showUpsertDialog(context, ref, null),
        ),
        body: state.loading
            ? const Center(child: CircularProgressIndicator())
            : state.entries.isEmpty
                ? const Center(
                    child: Text('No Voice of Trust entries yet. Use the + button to add one.',
                        style: TextStyle(color: _kMutedColor)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _EntryCard(
                      entry: state.entries[i],
                      onEdit: () => _showUpsertDialog(context, ref, state.entries[i]),
                      onDelete: () => _confirmDelete(context, ref, state.entries[i]),
                      onToggle: (val) => ref.read(voiceOfTrustProvider.notifier).update(
                            state.entries[i].id,
                            title: state.entries[i].title,
                            description: state.entries[i].description,
                            order: state.entries[i].order,
                            isActive: val,
                          ),
                    ),
                  ),
      ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref, VoiceOfTrustModel entry) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Delete Entry', style: TextStyle(fontWeight: FontWeight.w700, color: _kTitleColor)),
      content: Text('Delete "${entry.title}"? This also removes its customer reviews. This cannot be undone.'),
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
  final success = await ref.read(voiceOfTrustProvider.notifier).delete(entry.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Entry deleted' : 'Delete failed'),
      backgroundColor: success ? AppColors.royalBlue : Colors.red,
    ));
  }
}

class _EntryCard extends StatelessWidget {
  final VoiceOfTrustModel entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _EntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: entry.image != null
                ? CachedNetworkImage(
                    imageUrl: entry.image!,
                    width: 72,
                    height: 64,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _kTitleColor)),
                const SizedBox(height: 4),
                Text(entry.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _kMutedColor, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Switch(
                value: entry.isActive,
                activeThumbColor: _kPrimary,
                onChanged: onToggle,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: _kPrimary),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 72,
        height: 64,
        color: _kMainBg,
        child: const Icon(Icons.favorite_outline, color: _kMutedColor),
      );
}

Future<void> _showUpsertDialog(BuildContext context, WidgetRef ref, VoiceOfTrustModel? existing) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final orderCtrl = TextEditingController(text: existing?.order.toString() ?? '0');
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
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'Add Voice of Trust Entry' : 'Edit Entry',
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
                                    Text('Click to choose an image (optional)',
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
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Display order'),
                  ),
                  if (existing != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text('Active', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _kTitleColor)),
                        const Spacer(),
                        Switch(
                          value: isActive,
                          activeThumbColor: _kPrimary,
                          onChanged: (v) => setLocal(() => isActive = v),
                        ),
                      ],
                    ),
                  ],
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
                                bool ok;
                                if (existing == null) {
                                  ok = await ref.read(voiceOfTrustProvider.notifier).create(
                                        title: titleCtrl.text.trim(),
                                        description: descCtrl.text.trim(),
                                        order: int.tryParse(orderCtrl.text) ?? 0,
                                        imageBytes: pickedBytes,
                                        fileName: pickedName,
                                      );
                                } else {
                                  ok = await ref.read(voiceOfTrustProvider.notifier).update(
                                        existing.id,
                                        title: titleCtrl.text.trim(),
                                        description: descCtrl.text.trim(),
                                        order: int.tryParse(orderCtrl.text) ?? 0,
                                        isActive: isActive,
                                        imageBytes: pickedBytes,
                                        fileName: pickedName,
                                      );
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(ok ? (existing == null ? 'Entry added' : 'Entry updated') : 'Something went wrong'),
                                    backgroundColor: ok ? AppColors.royalBlue : Colors.red,
                                  ));
                                }
                              },
                        child: loading
                            ? const SizedBox(
                                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
