import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../core/network/api_exception.dart';
import '../../models/review_model.dart';
import '../../models/voice_of_trust_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/voice_of_trust_provider.dart';
import '../../widgets/auth_modal.dart';
import '../../widgets/common.dart';

/// Public "Voices of Trust" section — admin-managed entries, each with its
/// own customer reviews and a "Write a Review" action.
class VoiceOfTrustSection extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigate;
  const VoiceOfTrustSection({super.key, this.onNavigate});

  @override
  ConsumerState<VoiceOfTrustSection> createState() => _VoiceOfTrustSectionState();
}

class _VoiceOfTrustSectionState extends ConsumerState<VoiceOfTrustSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceOfTrustProvider.notifier).loadActive();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceOfTrustProvider);

    return Container(
      width: double.infinity,
      color: AppColors.lightBlueBg,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
        child: Column(
          children: [
            const SectionTitle(
              title: 'Voices of Trust',
              subtitle: 'Hear what parents and professionals say about our Cambridge English '
                  'programs — and share your own experience with us.',
            ),
            const SizedBox(height: 40),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              )
            else if (state.entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No testimonials yet — check back soon.', style: TextStyle(color: AppColors.mutedText)),
              )
            else
              ResponsiveGrid(
                columnsFor: (w) => w >= 900 ? 3 : 1,
                children: state.entries.map((e) => _VoiceOfTrustCard(entry: e)).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _VoiceOfTrustCard extends ConsumerStatefulWidget {
  final VoiceOfTrustModel entry;
  const _VoiceOfTrustCard({required this.entry});

  @override
  ConsumerState<_VoiceOfTrustCard> createState() => _VoiceOfTrustCardState();
}

class _VoiceOfTrustCardState extends ConsumerState<_VoiceOfTrustCard> {
  List<ReviewModel> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ref.read(reviewRepositoryProvider).getForVoiceOfTrust(widget.entry.id);
      if (mounted) {
        setState(() {
          _reviews = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openReviewForm() async {
    if (ref.read(authProvider).status != AuthStatus.authenticated) {
      showLoginModal(context);
      return;
    }
    final thankYou = await showDialog<String>(
      context: context,
      builder: (_) => _ReviewFormDialog(voiceOfTrustId: widget.entry.id),
    );
    if (thankYou == null || !mounted) return;
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(thankYou),
        backgroundColor: AppColors.royalBlue,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: entry.image != null
                    ? CachedNetworkImage(imageUrl: entry.image!, width: 48, height: 48, fit: BoxFit.cover)
                    : Container(
                        width: 48,
                        height: 48,
                        color: AppColors.royalBlue.withValues(alpha: 0.12),
                        child: const Icon(Icons.favorite, color: AppColors.royalBlue),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(entry.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.darkNavy)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(entry.description, style: const TextStyle(color: AppColors.darkText, height: 1.6, fontSize: 14)),
          const SizedBox(height: 18),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_reviews.isEmpty)
            const Text('Be the first to share your experience.',
                style: TextStyle(color: AppColors.mutedText, fontStyle: FontStyle.italic, fontSize: 13))
          else
            ..._reviews.take(3).map((r) => _ReviewTile(review: r)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _openReviewForm,
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Write a Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.darkNavy)),
              if (review.rating != null) ...[
                const SizedBox(width: 6),
                Row(children: List.generate(review.rating!, (_) => const Icon(Icons.star, size: 12, color: AppColors.gold))),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text('"${review.message}"', style: const TextStyle(fontSize: 13, color: AppColors.darkText, height: 1.4)),
          if (review.adminReply != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('— Reply: ${review.adminReply}',
                  style: const TextStyle(fontSize: 12, color: AppColors.royalBlue, fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewFormDialog extends ConsumerStatefulWidget {
  final String voiceOfTrustId;
  const _ReviewFormDialog({required this.voiceOfTrustId});

  @override
  ConsumerState<_ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends ConsumerState<_ReviewFormDialog> {
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final (_, thankYou) = await ref.read(reviewRepositoryProvider).create(
            voiceOfTrustId: widget.voiceOfTrustId,
            message: _messageCtrl.text.trim(),
            rating: _rating,
          );
      if (mounted) Navigator.pop(context, thankYou);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e is ApiException ? e.message : 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Write a Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                const SizedBox(height: 6),
                Text(
                  'Posting as ${ref.watch(authProvider).user?.name ?? 'you'}',
                  style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _messageCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Your review *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please write a short review' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Rating:', style: TextStyle(color: AppColors.mutedText, fontSize: 13)),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (i) {
                        final filled = i < _rating;
                        return IconButton(
                          onPressed: () => setState(() => _rating = i + 1),
                          icon: Icon(filled ? Icons.star : Icons.star_border, color: AppColors.gold, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        );
                      }),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.royalBlue),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit Review'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
