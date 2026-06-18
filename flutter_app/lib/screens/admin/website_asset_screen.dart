import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_theme.dart';
import '../../models/website_asset_model.dart';
import '../../providers/website_asset_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);
const _kMainBg = Color(0xFFF4F5FA);

class _Tab {
  final String label;
  final IconData icon;
  final String? assetType; // null = all (URLs tab)
  const _Tab(this.label, this.icon, this.assetType);
}

const _kTabs = [
  _Tab('Hero Images', Icons.slideshow_outlined, 'hero'),
  _Tab('Videos', Icons.videocam_outlined, 'video'),
  _Tab('Banners', Icons.view_carousel_outlined, 'banner'),
  _Tab('URLs', Icons.link, null),
];

class WebsiteAssetScreen extends ConsumerStatefulWidget {
  const WebsiteAssetScreen({super.key});

  @override
  ConsumerState<WebsiteAssetScreen> createState() => _WebsiteAssetScreenState();
}

class _WebsiteAssetScreenState extends ConsumerState<WebsiteAssetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _kTabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(websiteAssetProvider.notifier).loadAdminAll());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(websiteAssetProvider);

    return AdminShell(
      activeRoute: Routes.adminWebsiteAssets,
      breadcrumbs: const ['Admin', 'Website Assets'],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: _kPrimary,
              unselectedLabelColor: _kMutedColor,
              indicatorColor: _kPrimary,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: _kTabs
                  .map((t) => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(t.icon, size: 16), const SizedBox(width: 7), Text(t.label)],
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabs,
                    children: _kTabs
                        .map((t) => _AssetTab(
                              tab: t,
                              assets: t.assetType == null
                                  ? state.assets
                                  : state.assets.where((a) => a.assetType == t.assetType).toList(),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AssetTab extends ConsumerWidget {
  final _Tab tab;
  final List<WebsiteAssetModel> assets;
  const _AssetTab({required this.tab, required this.assets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrlsTab = tab.assetType == null;
    return Scaffold(
      backgroundColor: _kMainBg,
      floatingActionButton: isUrlsTab
          ? null
          : FloatingActionButton.extended(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text('Add ${tab.label}', style: const TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () => _showUpsertDialog(context, ref, tab.assetType!, null),
            ),
      body: assets.isEmpty
          ? Center(
              child: Text(
                isUrlsTab ? 'No assets yet.' : 'No ${tab.label.toLowerCase()} yet. Use the + button to add one.',
                style: const TextStyle(color: _kMutedColor),
              ),
            )
          : isUrlsTab
              ? ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: assets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _UrlRow(
                    asset: assets[i],
                    onEdit: () => _showUpsertDialog(context, ref, assets[i].assetType, assets[i]),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(builder: (_, constraints) {
                    final cols = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 600 ? 3 : 2);
                    const gap = 16.0;
                    final cardW = (constraints.maxWidth - gap * (cols - 1)) / cols;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: assets
                          .map((a) => _AssetCard(
                                asset: a,
                                width: cardW,
                                onEdit: () => _showUpsertDialog(context, ref, a.assetType, a),
                                onDelete: () => _confirmDelete(context, ref, a),
                                onToggle: (val) => ref.read(websiteAssetProvider.notifier).update(
                                      a.id,
                                      status: val ? 'active' : 'inactive',
                                    ),
                              ))
                          .toList(),
                    );
                  }),
                ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref, WebsiteAssetModel asset) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Delete Asset', style: TextStyle(fontWeight: FontWeight.w700, color: _kTitleColor)),
      content: Text('Delete "${asset.title ?? asset.assetType}"? This cannot be undone.'),
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
  final success = await ref.read(websiteAssetProvider.notifier).delete(asset.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Asset deleted' : 'Delete failed'),
      backgroundColor: success ? AppColors.royalBlue : Colors.red,
    ));
  }
}

class _UrlRow extends StatelessWidget {
  final WebsiteAssetModel asset;
  final VoidCallback onEdit;
  const _UrlRow({required this.asset, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            asset.assetType == 'video' ? Icons.videocam_outlined : Icons.image_outlined,
            size: 18,
            color: _kMutedColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(asset.title ?? '(${asset.assetType})',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: _kTitleColor)),
          ),
          Expanded(
            flex: 3,
            child: Text(asset.redirectUrl ?? '— no URL set —',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: asset.redirectUrl == null ? _kMutedColor : const Color(0xFF374151))),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: _kPrimary), onPressed: onEdit, tooltip: 'Edit URL'),
        ],
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final WebsiteAssetModel asset;
  final double width;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _AssetCard({
    required this.asset,
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
                  if (asset.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: asset.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const ColoredBox(color: _kMainBg),
                    )
                  else if (asset.assetType == 'video' && asset.videoUrl != null)
                    const ColoredBox(
                      color: Color(0xFF1A1D3D),
                      child: Icon(Icons.play_circle_outline, color: Colors.white, size: 36),
                    )
                  else
                    const ColoredBox(color: _kMainBg, child: Icon(Icons.image_not_supported_outlined, color: _kMutedColor)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: asset.isActive ? const Color(0xFF22C55E) : _kMutedColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(asset.isActive ? 'Active' : 'Hidden',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset.title ?? '(untitled)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kTitleColor)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        alignment: Alignment.centerLeft,
                        child: Switch(value: asset.isActive, activeThumbColor: _kPrimary, onChanged: onToggle),
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
}

Future<void> _showUpsertDialog(
  BuildContext context,
  WidgetRef ref,
  String assetType,
  WebsiteAssetModel? existing,
) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final redirectCtrl = TextEditingController(text: existing?.redirectUrl ?? '');
  final orderCtrl = TextEditingController(text: existing?.sortOrder.toString() ?? '0');
  Uint8List? pickedImageBytes;
  String? pickedImageName;
  String? previewImageUrl = existing?.imageUrl;
  Uint8List? pickedVideoBytes;
  String? pickedVideoName;
  bool hasExistingVideo = existing?.videoUrl != null;
  bool loading = false;
  final isVideo = assetType == 'video';

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Add Asset' : 'Edit Asset',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kTitleColor),
                ),
                const SizedBox(height: 4),
                Text(assetType, style: const TextStyle(fontSize: 13, color: _kMutedColor)),
                const SizedBox(height: 20),

                // Image picker (always available — used as thumbnail/cover even for video assets)
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final xfile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 90);
                    if (xfile == null) return;
                    final bytes = await xfile.readAsBytes();
                    setLocal(() {
                      pickedImageBytes = bytes;
                      pickedImageName = xfile.name;
                      previewImageUrl = null;
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
                    child: pickedImageBytes != null
                        ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
                        : previewImageUrl != null
                            ? CachedNetworkImage(imageUrl: previewImageUrl!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, size: 38, color: _kMutedColor),
                                  const SizedBox(height: 8),
                                  Text(isVideo ? 'Click to choose a cover image (optional)' : 'Click to choose an image',
                                      style: const TextStyle(fontSize: 12, color: _kMutedColor)),
                                ],
                              ),
                  ),
                ),
                if (isVideo) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final xfile = await picker.pickVideo(source: ImageSource.gallery);
                      if (xfile == null) return;
                      final bytes = await xfile.readAsBytes();
                      setLocal(() {
                        pickedVideoBytes = bytes;
                        pickedVideoName = xfile.name;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _kMainBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorderColor, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            pickedVideoBytes != null || hasExistingVideo ? Icons.check_circle : Icons.videocam_outlined,
                            color: pickedVideoBytes != null || hasExistingVideo ? const Color(0xFF22C55E) : _kMutedColor,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pickedVideoBytes != null
                                ? pickedVideoName ?? 'Video selected'
                                : hasExistingVideo
                                    ? 'Video already uploaded — tap to replace'
                                    : 'Tap to choose a video file',
                            style: const TextStyle(fontSize: 12, color: _kMutedColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (existing == null && pickedVideoBytes == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Video required', style: TextStyle(color: Colors.red, fontSize: 11)),
                    ),
                ],
                const SizedBox(height: 20),

                TextField(controller: titleCtrl, decoration: _inputDeco('Title')),
                const SizedBox(height: 14),
                TextField(controller: redirectCtrl, decoration: _inputDeco('Redirect URL (optional)')),
                const SizedBox(height: 14),
                TextField(controller: orderCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Display order')),

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
                              if (isVideo && existing == null && pickedVideoBytes == null) return;
                              setLocal(() => loading = true);
                              bool ok;
                              final redirect = redirectCtrl.text.trim().isEmpty ? null : redirectCtrl.text.trim();
                              final title = titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim();
                              final order = int.tryParse(orderCtrl.text) ?? 0;
                              if (existing == null) {
                                ok = await ref.read(websiteAssetProvider.notifier).create(
                                      assetType: assetType,
                                      title: title,
                                      redirectUrl: redirect,
                                      sortOrder: order,
                                      imageBytes: pickedImageBytes,
                                      imageFileName: pickedImageName,
                                      videoBytes: pickedVideoBytes,
                                      videoFileName: pickedVideoName,
                                    );
                              } else {
                                ok = await ref.read(websiteAssetProvider.notifier).update(
                                      existing.id,
                                      title: title,
                                      redirectUrl: redirect,
                                      sortOrder: order,
                                      imageBytes: pickedImageBytes,
                                      imageFileName: pickedImageName,
                                      videoBytes: pickedVideoBytes,
                                      videoFileName: pickedVideoName,
                                    );
                              }
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(ok ? (existing == null ? 'Asset added' : 'Asset updated') : 'Something went wrong'),
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
  );

  titleCtrl.dispose();
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
