import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/api_constants.dart';
import '../../providers/app_providers.dart';
import '../../providers/notification_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);

/// Shows recent unread contact-message notifications for the admin.
/// Tapping an item opens the full Contact Messages screen (and marks it read).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
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
        _messages = data
            .cast<Map<String, dynamic>>()
            .where((m) => m['isRead'] == false)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openMessage(Map<String, dynamic> m) async {
    try {
      await ref.read(dioClientProvider).dio.patch('/contact/${m['_id']}/read');
    } catch (_) {}
    ref.read(unreadMessagesProvider.notifier).refresh();
    if (mounted) context.push(Routes.adminContacts);
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeRoute: Routes.adminNotifications,
      breadcrumbs: const ['Admin', 'Notifications'],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                _messages.isEmpty
                    ? 'No new notifications'
                    : '${_messages.length} unread message${_messages.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kTitleColor),
              ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_outlined,
                        size: 48, color: _kMutedColor),
                    SizedBox(height: 12),
                    Text("You're all caught up!",
                        style: TextStyle(color: _kMutedColor, fontSize: 14)),
                  ],
                ),
              ))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final m = _messages[i];
                    return Card(
                      elevation: 0,
                      color: const Color(0xFFF0F4FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: _kPrimary.withValues(alpha: 0.25)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openMessage(m),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    _kPrimary.withValues(alpha: 0.12),
                                child: Text(
                                  (m['name'] as String? ?? '?')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _kPrimary),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                          'New message from ${m['name'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: _kTitleColor),
                                        ),
                                      ),
                                      Container(
                                          width: 8,
                                          height: 8,
                                          margin:
                                              const EdgeInsets.only(left: 8, top: 4),
                                          decoration: const BoxDecoration(
                                              color: _kPrimary,
                                              shape: BoxShape.circle)),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subject: ${m['subject'] ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _kTitleColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      m['message'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: _kMutedColor,
                                          height: 1.4),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _timeAgo(m['createdAt'] as String?),
                                      style: const TextStyle(
                                          fontSize: 11, color: _kMutedColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
