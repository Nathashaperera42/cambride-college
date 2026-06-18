import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../providers/voice_of_trust_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);

class ReviewListScreen extends ConsumerStatefulWidget {
  const ReviewListScreen({super.key});

  @override
  ConsumerState<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends ConsumerState<ReviewListScreen> {
  String? _filterVoiceOfTrustId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceOfTrustProvider.notifier).loadAdminAll();
      ref.read(reviewProvider.notifier).loadAdminAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);
    final entries = ref.watch(voiceOfTrustProvider).entries;

    return AdminShell(
      activeRoute: Routes.adminReviews,
      breadcrumbs: const ['Admin', 'Review Management'],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Filter by entry:', style: TextStyle(fontSize: 13, color: _kMutedColor)),
                const SizedBox(width: 10),
                DropdownButton<String?>(
                  value: _filterVoiceOfTrustId,
                  hint: const Text('All entries'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All entries')),
                    ...entries.map((e) => DropdownMenuItem<String?>(value: e.id, child: Text(e.title))),
                  ],
                  onChanged: (v) {
                    setState(() => _filterVoiceOfTrustId = v);
                    ref.read(reviewProvider.notifier).loadAdminAll(voiceOfTrustId: v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.reviews.isEmpty)
              const Expanded(child: Center(child: Text('No reviews yet.', style: TextStyle(color: _kMutedColor))))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: state.reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ReviewCard(
                    review: state.reviews[i],
                    onReply: () => _showReplyDialog(context, ref, state.reviews[i]),
                    onDelete: () => _confirmDelete(context, ref, state.reviews[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref, ReviewModel review) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Review', style: TextStyle(color: _kTitleColor, fontWeight: FontWeight.w700)),
      content: Text('Delete the review from "${review.customerName}"? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final success = await ref.read(reviewProvider.notifier).delete(review.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Review deleted' : 'Delete failed'),
      backgroundColor: success ? AppColors.royalBlue : Colors.red,
    ));
  }
}

Future<void> _showReplyDialog(BuildContext context, WidgetRef ref, ReviewModel review) async {
  final replyCtrl = TextEditingController(text: review.adminReply ?? '');
  bool loading = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reply to Review', style: TextStyle(fontWeight: FontWeight.w700, color: _kTitleColor)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('"${review.message}"', style: const TextStyle(fontStyle: FontStyle.italic, color: _kMutedColor)),
              const SizedBox(height: 16),
              TextField(
                controller: replyCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Your reply',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: loading ? null : () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kPrimary),
            onPressed: loading
                ? null
                : () async {
                    if (replyCtrl.text.trim().isEmpty) return;
                    setLocal(() => loading = true);
                    final ok = await ref.read(reviewProvider.notifier).reply(review.id, replyCtrl.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'Reply saved' : 'Failed to save reply'),
                        backgroundColor: ok ? AppColors.royalBlue : Colors.red,
                      ));
                    }
                  },
            child: loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Reply'),
          ),
        ],
      ),
    ),
  );

  replyCtrl.dispose();
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const _ReviewCard({required this.review, required this.onReply, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(review.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kTitleColor)),
              ),
              if (review.rating != null)
                Row(
                  children: List.generate(
                    review.rating!,
                    (_) => const Icon(Icons.star, size: 14, color: Color(0xFFE8B21D)),
                  ),
                ),
            ],
          ),
          if (review.voiceOfTrustTitle != null) ...[
            const SizedBox(height: 2),
            Text('on "${review.voiceOfTrustTitle}"', style: const TextStyle(fontSize: 11, color: _kMutedColor)),
          ],
          const SizedBox(height: 8),
          Text(review.message, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.5)),
          if (review.adminReply != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5FA),
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: _kPrimary, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Admin reply', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: _kPrimary)),
                  const SizedBox(height: 4),
                  Text(review.adminReply!, style: const TextStyle(fontSize: 13, color: _kTitleColor)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onReply,
                icon: const Icon(Icons.reply, size: 16),
                label: Text(review.adminReply == null ? 'Reply' : 'Edit Reply'),
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
    );
  }
}
