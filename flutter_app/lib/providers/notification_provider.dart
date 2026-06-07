import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import 'app_providers.dart';

/// Tracks the count of unread contact messages so the admin shell can show
/// a live notification badge. Polls the contact-messages endpoint and can
/// also be refreshed on demand (e.g. after marking a message as read).
class UnreadMessagesNotifier extends StateNotifier<int> {
  final Ref _ref;
  Timer? _timer;

  UnreadMessagesNotifier(this._ref) : super(0) {
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  Future<void> refresh() async {
    try {
      final res = await _ref
          .read(dioClientProvider)
          .dio
          .get(ApiConstants.contactAdmin);
      final messages = res.data['data']['messages'] as List? ?? [];
      state = messages.where((m) => m['isRead'] == false).length;
    } catch (_) {
      // Keep last known count on failure.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final unreadMessagesProvider =
    StateNotifierProvider<UnreadMessagesNotifier, int>((ref) {
  return UnreadMessagesNotifier(ref);
});
