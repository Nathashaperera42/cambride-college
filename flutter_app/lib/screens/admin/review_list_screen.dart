import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../models/course_review_model.dart';
import '../../models/review_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/course_review_provider.dart';
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

class _ReviewListScreenState extends ConsumerState<ReviewListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeRoute: Routes.adminReviews,
      breadcrumbs: const ['Admin', 'Review Management'],
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
              tabs: const [
                Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.favorite_outline, size: 16),
                    SizedBox(width: 7),
                    Text('Voice of Trust'),
                  ]),
                ),
                Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.menu_book_outlined, size: 16),
                    SizedBox(width: 7),
                    Text('Courses'),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [_VoiceOfTrustReviewsTab(), _CourseReviewsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VOICE OF TRUST REVIEWS
// ---------------------------------------------------------------------------

class _VoiceOfTrustReviewsTab extends ConsumerStatefulWidget {
  const _VoiceOfTrustReviewsTab();

  @override
  ConsumerState<_VoiceOfTrustReviewsTab> createState() => _VoiceOfTrustReviewsTabState();
}

class _VoiceOfTrustReviewsTabState extends ConsumerState<_VoiceOfTrustReviewsTab> {
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

    return Padding(
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
                itemBuilder: (_, i) => _VoiceOfTrustReviewCard(
                  review: state.reviews[i],
                  onReply: () => _showVoiceOfTrustReplyDialog(context, ref, state.reviews[i]),
                  onDelete: () => _confirmDeleteVoiceOfTrustReview(context, ref, state.reviews[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteVoiceOfTrustReview(BuildContext context, WidgetRef ref, ReviewModel review) async {
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

Future<void> _showVoiceOfTrustReplyDialog(BuildContext context, WidgetRef ref, ReviewModel review) async {
  await _showReplyDialog(
    context: context,
    quotedMessage: review.message,
    initialReply: review.adminReply,
    onSave: (text) => ref.read(reviewProvider.notifier).reply(review.id, text),
  );
}

class _VoiceOfTrustReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const _VoiceOfTrustReviewCard({required this.review, required this.onReply, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return _ReviewCardShell(
      name: review.customerName,
      rating: review.rating,
      subtitle: review.voiceOfTrustTitle != null ? 'on "${review.voiceOfTrustTitle}"' : null,
      message: review.message,
      adminReply: review.adminReply,
      onReply: onReply,
      onDelete: onDelete,
    );
  }
}

// ---------------------------------------------------------------------------
// COURSE REVIEWS
// ---------------------------------------------------------------------------

class _CourseReviewsTab extends ConsumerStatefulWidget {
  const _CourseReviewsTab();

  @override
  ConsumerState<_CourseReviewsTab> createState() => _CourseReviewsTabState();
}

class _CourseReviewsTabState extends ConsumerState<_CourseReviewsTab> {
  String? _filterCourseId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseProvider.notifier).loadAdminCourses();
      ref.read(courseReviewProvider.notifier).loadAdminAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseReviewProvider);
    final courses = ref.watch(courseProvider).courses;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Filter by course:', style: TextStyle(fontSize: 13, color: _kMutedColor)),
              const SizedBox(width: 10),
              DropdownButton<String?>(
                value: _filterCourseId,
                hint: const Text('All courses'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All courses')),
                  ...courses.map((c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.title))),
                ],
                onChanged: (v) {
                  setState(() => _filterCourseId = v);
                  ref.read(courseReviewProvider.notifier).loadAdminAll(courseId: v);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.reviews.isEmpty)
            const Expanded(child: Center(child: Text('No course reviews yet.', style: TextStyle(color: _kMutedColor))))
          else
            Expanded(
              child: ListView.separated(
                itemCount: state.reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _CourseReviewCard(
                  review: state.reviews[i],
                  onReply: () => _showCourseReplyDialog(context, ref, state.reviews[i]),
                  onDelete: () => _confirmDeleteCourseReview(context, ref, state.reviews[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteCourseReview(BuildContext context, WidgetRef ref, CourseReviewModel review) async {
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
  final success = await ref.read(courseReviewProvider.notifier).delete(review.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Review deleted' : 'Delete failed'),
      backgroundColor: success ? AppColors.royalBlue : Colors.red,
    ));
  }
}

Future<void> _showCourseReplyDialog(BuildContext context, WidgetRef ref, CourseReviewModel review) async {
  await _showReplyDialog(
    context: context,
    quotedMessage: review.message ?? '(no comment, rating only)',
    initialReply: review.adminReply,
    onSave: (text) => ref.read(courseReviewProvider.notifier).reply(review.id, text),
  );
}

class _CourseReviewCard extends StatelessWidget {
  final CourseReviewModel review;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const _CourseReviewCard({required this.review, required this.onReply, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return _ReviewCardShell(
      name: review.customerName,
      rating: review.rating,
      subtitle: review.courseTitle != null ? 'on "${review.courseTitle}"' : null,
      message: review.message ?? '(no comment, rating only)',
      adminReply: review.adminReply,
      onReply: onReply,
      onDelete: onDelete,
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED UI
// ---------------------------------------------------------------------------

Future<void> _showReplyDialog({
  required BuildContext context,
  required String quotedMessage,
  required String? initialReply,
  required Future<bool> Function(String text) onSave,
}) async {
  final replyCtrl = TextEditingController(text: initialReply ?? '');
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
              Text('"$quotedMessage"', style: const TextStyle(fontStyle: FontStyle.italic, color: _kMutedColor)),
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
                    final ok = await onSave(replyCtrl.text.trim());
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

class _ReviewCardShell extends StatelessWidget {
  final String name;
  final int? rating;
  final String? subtitle;
  final String message;
  final String? adminReply;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const _ReviewCardShell({
    required this.name,
    required this.rating,
    required this.subtitle,
    required this.message,
    required this.adminReply,
    required this.onReply,
    required this.onDelete,
  });

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
                child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kTitleColor)),
              ),
              if (rating != null)
                Row(
                  children: List.generate(rating!, (_) => const Icon(Icons.star, size: 14, color: Color(0xFFE8B21D))),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: const TextStyle(fontSize: 11, color: _kMutedColor)),
          ],
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.5)),
          if (adminReply != null) ...[
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
                  Text(adminReply!, style: const TextStyle(fontSize: 13, color: _kTitleColor)),
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
                label: Text(adminReply == null ? 'Reply' : 'Edit Reply'),
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
