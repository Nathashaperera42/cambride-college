import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/app_providers.dart';
import '../../providers/notification_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kGreen = Color(0xFF16A34A);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);

class ContactMessagesScreen extends ConsumerStatefulWidget {
  const ContactMessagesScreen({super.key});

  @override
  ConsumerState<ContactMessagesScreen> createState() =>
      _ContactMessagesScreenState();
}

class _ContactMessagesScreenState
    extends ConsumerState<ContactMessagesScreen> {
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ref
          .read(dioClientProvider)
          .dio
          .get(ApiConstants.contactAdmin);
      final data = res.data['data']['messages'] as List? ?? [];
      setState(() {
        _messages = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
      ref.read(unreadMessagesProvider.notifier).refresh();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markRead(String id) async {
    try {
      await ref.read(dioClientProvider).dio.patch('/contact/$id/read');
      final idx = _messages.indexWhere((m) => m['_id'] == id);
      if (idx >= 0) {
        setState(() => _messages[idx] = {..._messages[idx], 'isRead': true});
      }
      ref.read(unreadMessagesProvider.notifier).refresh();
    } catch (_) {}
  }

  Future<void> _delete(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Delete this inquiry? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(dioClientProvider).dio.delete('/contact/$id');
        setState(() => _messages.removeWhere((m) => m['_id'] == id));
        ref.read(unreadMessagesProvider.notifier).refresh();
      } catch (e) {
        messenger.showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showReplyDialog(Map<String, dynamic> message) async {
    final replyCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    bool sending = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.reply_outlined,
                          color: _kPrimary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Reply to Message',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _kTitleColor)),
                            Text(
                              'To: ${message['name']}  <${message['email']}>',
                              style: const TextStyle(
                                  fontSize: 12, color: _kMutedColor),
                            ),
                          ]),
                    ),
                    IconButton(
                      onPressed: sending ? null : () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                          foregroundColor: _kMutedColor),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Original message preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FC),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                          left: BorderSide(color: Color(0xFFE8B21D), width: 3)),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject: ${message['subject'] ?? ''}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _kMutedColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message['message'] ?? '',
                            style: const TextStyle(
                                fontSize: 12,
                                color: _kTitleColor,
                                height: 1.4),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]),
                  ),
                  const SizedBox(height: 16),

                  // Reply text area
                  TextField(
                    controller: replyCtrl,
                    maxLines: 6,
                    enabled: !sending,
                    decoration: InputDecoration(
                      hintText: 'Write your reply here…',
                      hintStyle: const TextStyle(color: _kMutedColor),
                      filled: true,
                      fillColor: const Color(0xFFF4F4FB),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: _kBorderColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: _kBorderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: _kPrimary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            sending ? null : () => Navigator.pop(ctx),
                        child: const Text('Cancel',
                            style: TextStyle(color: _kMutedColor)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: sending
                            ? null
                            : () async {
                                final text = replyCtrl.text.trim();
                                if (text.isEmpty) {
                                  messenger.showSnackBar(const SnackBar(
                                    content:
                                        Text('Please write a reply first.'),
                                    backgroundColor: Colors.orange,
                                  ));
                                  return;
                                }
                                setDlgState(() => sending = true);
                                try {
                                  await ref
                                      .read(dioClientProvider)
                                      .dio
                                      .post(
                                    '/contact/${message['_id']}/reply',
                                    data: {'message': text},
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  // Mark read locally
                                  final idx = _messages.indexWhere(
                                      (m) => m['_id'] == message['_id']);
                                  if (idx >= 0) {
                                    setState(() => _messages[idx] = {
                                          ..._messages[idx],
                                          'isRead': true
                                        });
                                  }
                                  ref
                                      .read(unreadMessagesProvider.notifier)
                                      .refresh();
                                  messenger.showSnackBar(SnackBar(
                                    content: Text(
                                        'Reply sent to ${message['email']}'),
                                    backgroundColor: _kGreen,
                                  ));
                                } catch (e) {
                                  setDlgState(() => sending = false);
                                  messenger.showSnackBar(SnackBar(
                                    content: Text('Failed to send: $e'),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              },
                        icon: sending
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_outlined, size: 16),
                        label:
                            Text(sending ? 'Sending…' : 'Send Reply'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
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

    replyCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = _messages.where((m) => m['isRead'] == false).length;

    return AdminShell(
      activeRoute: Routes.adminContacts,
      breadcrumbs: const ['Admin', 'Contact Messages'],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (unread > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$unread unread',
                      style: const TextStyle(
                          color: _kPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                )
              else
                const Text('All messages read',
                    style: TextStyle(color: _kMutedColor, fontSize: 13)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.refresh, color: _kPrimary),
                  onPressed: _load,
                  tooltip: 'Refresh'),
            ]),
            const SizedBox(height: 12),
            if (_loading)
              const Expanded(
                  child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                  child: Center(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red))))
            else if (_messages.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text('No messages yet.',
                          style: TextStyle(color: _kMutedColor))))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final m = _messages[i];
                    final isRead = m['isRead'] == true;
                    return Card(
                      elevation: 0,
                      color:
                          isRead ? Colors.white : const Color(0xFFF0F4FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: isRead
                                ? _kBorderColor
                                : _kPrimary.withValues(alpha: 0.3)),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: isRead
                              ? const Color(0xFFF3F4F6)
                              : _kPrimary.withValues(alpha: 0.12),
                          child: Text(
                            (m['name'] as String? ?? '?')[0].toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isRead ? _kMutedColor : _kPrimary),
                          ),
                        ),
                        title: Row(children: [
                          Expanded(
                              child: Text(m['name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: _kTitleColor))),
                          if (!isRead)
                            Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: _kPrimary,
                                    shape: BoxShape.circle)),
                        ]),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m['email'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 12, color: _kMutedColor)),
                              Text('Subject: ${m['subject'] ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: _kTitleColor,
                                      fontWeight: FontWeight.w600)),
                            ]),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF8F8FC),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(m['message'] ?? '',
                                style: const TextStyle(
                                    height: 1.5, color: _kTitleColor)),
                          ),
                          const SizedBox(height: 8),
                          if (m['phone'] != null &&
                              (m['phone'] as String).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('Phone: ${m['phone']}',
                                  style: const TextStyle(
                                      fontSize: 12, color: _kMutedColor)),
                            ),
                          const SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Reply button
                                ElevatedButton.icon(
                                  onPressed: () => _showReplyDialog(m),
                                  icon: const Icon(Icons.reply_outlined,
                                      size: 15),
                                  label: const Text('Reply',
                                      style: TextStyle(fontSize: 13)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kPrimary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!isRead)
                                  TextButton.icon(
                                    onPressed: () =>
                                        _markRead(m['_id'] as String),
                                    icon: const Icon(
                                        Icons.mark_email_read_outlined,
                                        size: 16),
                                    label: const Text('Mark Read'),
                                    style: TextButton.styleFrom(
                                        foregroundColor: _kPrimary),
                                  ),
                                TextButton.icon(
                                  onPressed: () =>
                                      _delete(m['_id'] as String),
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                ),
                              ]),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
