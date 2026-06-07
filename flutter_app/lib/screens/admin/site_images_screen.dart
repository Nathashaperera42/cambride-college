import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

// ── Section meta ──────────────────────────────────────────────────────────────

class _Section {
  final String key;
  final String label;
  final IconData icon;
  const _Section(this.key, this.label, this.icon);
}

const _kSections = [
  _Section('hero_slider', 'Hero Slider', Icons.slideshow_outlined),
  _Section('about', 'About Page', Icons.info_outline),
  _Section('speech_drama', 'Speech & Drama', Icons.theater_comedy_outlined),
  _Section('events', 'Events', Icons.event_outlined),
  _Section('gallery', 'Gallery', Icons.photo_library_outlined),
];

// ── State ─────────────────────────────────────────────────────────────────────

class _SiteImagesState {
  final List<SiteImage> images;
  final bool loading;
  final String? error;

  const _SiteImagesState({
    this.images = const [],
    this.loading = false,
    this.error,
  });

  _SiteImagesState copyWith({
    List<SiteImage>? images,
    bool? loading,
    String? error,
  }) =>
      _SiteImagesState(
        images: images ?? this.images,
        loading: loading ?? this.loading,
        error: error,
      );
}

class _SiteImagesNotifier extends StateNotifier<_SiteImagesState> {
  final Ref ref;
  _SiteImagesNotifier(this.ref) : super(const _SiteImagesState());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list =
          await ref.read(siteImageRepositoryProvider).getAdminImages();
      state = state.copyWith(images: list, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> create({
    required String section,
    required String label,
    required String altText,
    required int order,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final img = await ref.read(siteImageRepositoryProvider).createImage(
            section: section,
            label: label,
            altText: altText,
            order: order,
            imageBytes: bytes,
            fileName: fileName,
          );
      state = state.copyWith(images: [...state.images, img]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> update(
    String id, {
    required String label,
    required String altText,
    required int order,
    required bool isActive,
    List<int>? bytes,
    String? fileName,
  }) async {
    try {
      final img = await ref.read(siteImageRepositoryProvider).updateImage(
            id,
            label: label,
            altText: altText,
            order: order,
            isActive: isActive,
            imageBytes: bytes,
            fileName: fileName,
          );
      state = state.copyWith(
        images: state.images.map((i) => i.id == id ? img : i).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await ref.read(siteImageRepositoryProvider).deleteImage(id);
      state =
          state.copyWith(images: state.images.where((i) => i.id != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final _siteImagesProvider =
    StateNotifierProvider<_SiteImagesNotifier, _SiteImagesState>(
  (ref) => _SiteImagesNotifier(ref),
);

// ── Screen ────────────────────────────────────────────────────────────────────

class SiteImagesScreen extends ConsumerStatefulWidget {
  const SiteImagesScreen({super.key});

  @override
  ConsumerState<SiteImagesScreen> createState() => _SiteImagesScreenState();
}

class _SiteImagesScreenState extends ConsumerState<SiteImagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _kSections.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(_siteImagesProvider.notifier).load());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_siteImagesProvider);

    return AdminShell(
      activeRoute: Routes.adminSiteImages,
      breadcrumbs: const ['Admin', 'Site Images'],
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF5558CF),
              unselectedLabelColor: const Color(0xFF9496B8),
              indicatorColor: const Color(0xFF5558CF),
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              tabs: _kSections
                  .map((s) => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(s.icon, size: 16),
                            const SizedBox(width: 7),
                            Text(s.label),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Body
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabs,
                    children: _kSections
                        .map((s) => _SectionTab(
                              section: s,
                              images: state.images
                                  .where((i) => i.section == s.key)
                                  .toList(),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Tab content for one section ───────────────────────────────────────────────

class _SectionTab extends ConsumerWidget {
  final _Section section;
  final List<SiteImage> images;
  const _SectionTab({required this.section, required this.images});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5558CF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add Image',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => _showUpsertDialog(context, ref, section.key, null),
      ),
      body: images.isEmpty
          ? _emptyState(section.label)
          : Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(builder: (_, constraints) {
                final cols = constraints.maxWidth >= 900
                    ? 4
                    : constraints.maxWidth >= 600
                        ? 3
                        : 2;
                const gap = 16.0;
                final cardW =
                    (constraints.maxWidth - gap * (cols - 1)) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: images
                      .map((img) => _ImageCard(
                            image: img,
                            width: cardW,
                            onEdit: () => _showUpsertDialog(
                                context, ref, section.key, img),
                            onDelete: () =>
                                _confirmDelete(context, ref, img),
                            onToggle: (val) => ref
                                .read(_siteImagesProvider.notifier)
                                .update(img.id,
                                    label: img.label,
                                    altText: img.altText,
                                    order: img.order,
                                    isActive: val),
                          ))
                      .toList(),
                );
              }),
            ),
    );
  }

  Widget _emptyState(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No images for $label yet',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9496B8))),
          const SizedBox(height: 6),
          const Text('Use the + button to add the first one.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9496B8))),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, SiteImage img) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Image',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D3D))),
        content: Text('Delete "${img.label}"? This cannot be undone.'),
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
    if (ok != true || !context.mounted) return;
    final success =
        await ref.read(_siteImagesProvider.notifier).delete(img.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Image deleted' : 'Delete failed'),
        backgroundColor: success ? AppColors.royalBlue : Colors.red,
      ));
    }
  }
}

// ── Add / Edit dialog ─────────────────────────────────────────────────────────

Future<void> _showUpsertDialog(
  BuildContext context,
  WidgetRef ref,
  String sectionKey,
  SiteImage? existing,
) async {
  final labelCtrl =
      TextEditingController(text: existing?.label ?? '');
  final altCtrl =
      TextEditingController(text: existing?.altText ?? '');
  final orderCtrl =
      TextEditingController(text: existing?.order.toString() ?? '0');
  bool isActive = existing?.isActive ?? true;
  Uint8List? pickedBytes;
  String? pickedName;
  String? previewUrl = existing?.imageUrl;
  bool loading = false;
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  // Title
                  Text(
                    existing == null ? 'Add Image' : 'Edit Image',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D3D)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _kSections
                        .firstWhere((s) => s.key == sectionKey)
                        .label,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF9496B8)),
                  ),
                  const SizedBox(height: 24),

                  // Image picker area
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final xfile = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1400,
                          imageQuality: 90);
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
                      height: 190,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE8E8F0), width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: pickedBytes != null
                          ? Image.memory(
                              pickedBytes!,
                              fit: BoxFit.cover,
                            )
                          : previewUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: previewUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                        size: 42,
                                        color: Color(0xFF9496B8)),
                                    SizedBox(height: 10),
                                    Text('Click to choose an image',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9496B8))),
                                  ],
                                ),
                    ),
                  ),
                  if (existing == null && pickedBytes == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Image required',
                          style:
                              TextStyle(color: Colors.red, fontSize: 11)),
                    ),
                  const SizedBox(height: 20),

                  // Label
                  TextFormField(
                    controller: labelCtrl,
                    decoration: _inputDeco('Label *', Icons.label_outline),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Label is required'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Alt text
                  TextFormField(
                    controller: altCtrl,
                    decoration: _inputDeco(
                        'Alt text (accessibility)', Icons.accessibility_new),
                  ),
                  const SizedBox(height: 14),

                  // Order
                  TextFormField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Display order', Icons.sort),
                  ),
                  const SizedBox(height: 14),

                  // Active toggle
                  if (existing != null)
                    Row(
                      children: [
                        const Text('Active',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1A1D3D))),
                        const Spacer(),
                        Switch(
                          value: isActive,
                          activeThumbColor: const Color(0xFF5558CF),
                          onChanged: (v) => setLocal(() => isActive = v),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: loading
                            ? null
                            : () => Navigator.pop(ctx),
                        child: const Text('Cancel',
                            style:
                                TextStyle(color: Color(0xFF9496B8))),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5558CF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: loading
                            ? null
                            : () async {
                                if (existing == null &&
                                    pickedBytes == null) {
                                  return;
                                }
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                setLocal(() => loading = true);
                                bool ok;
                                if (existing == null) {
                                  ok = await ref
                                      .read(_siteImagesProvider.notifier)
                                      .create(
                                        section: sectionKey,
                                        label: labelCtrl.text.trim(),
                                        altText: altCtrl.text.trim(),
                                        order: int.tryParse(
                                                orderCtrl.text) ??
                                            0,
                                        bytes: pickedBytes!,
                                        fileName: pickedName!,
                                      );
                                } else {
                                  ok = await ref
                                      .read(_siteImagesProvider.notifier)
                                      .update(
                                        existing.id,
                                        label: labelCtrl.text.trim(),
                                        altText: altCtrl.text.trim(),
                                        order: int.tryParse(
                                                orderCtrl.text) ??
                                            0,
                                        isActive: isActive,
                                        bytes: pickedBytes,
                                        fileName: pickedName,
                                      );
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(ok
                                        ? existing == null
                                            ? 'Image added'
                                            : 'Image updated'
                                        : 'Something went wrong'),
                                    backgroundColor: ok
                                        ? AppColors.royalBlue
                                        : Colors.red,
                                  ));
                                }
                              },
                        child: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : Text(
                                existing == null ? 'Upload' : 'Save',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
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

  labelCtrl.dispose();
  altCtrl.dispose();
  orderCtrl.dispose();
}

InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9496B8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF5558CF), width: 1.5)),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );

// ── Image card ────────────────────────────────────────────────────────────────

class _ImageCard extends StatelessWidget {
  final SiteImage image;
  final double width;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _ImageCard({
    required this.image,
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
          border: Border.all(color: const Color(0xFFE8E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: Color(0xFFF4F5FA)),
                    errorWidget: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFF4F5FA)),
                  ),
                  // Active badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: image.isActive
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF9496B8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        image.isActive ? 'Active' : 'Hidden',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  // Order badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${image.order}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info + actions
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1A1D3D)),
                  ),
                  if (image.altText.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      image.altText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9496B8)),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Active toggle
                      Transform.scale(
                        scale: 0.8,
                        alignment: Alignment.centerLeft,
                        child: Switch(
                          value: image.isActive,
                          activeThumbColor: const Color(0xFF5558CF),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: onToggle,
                        ),
                      ),
                      const Spacer(),
                      // Edit
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: const Color(0xFF5558CF),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        tooltip: 'Edit',
                      ),
                      // Delete
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
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
}
