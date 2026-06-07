import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTableHeaderBg = Color(0xFFEAECFF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kBodyText = Color(0xFF4A4A72);
const _kMuted = Color(0xFF9496B8);
const _kBorder = Color(0xFFE8E8F0);
const _kGreen = Color(0xFF22C55E);
const _kGreenText = Color(0xFF16A34A);

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(UserModel u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${u.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(userListProvider.notifier).deleteUser(u.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);

    return AdminShell(
      activeRoute: Routes.userList,
      breadcrumbs: const ['Admin', 'Clients'],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: 'Search in table',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: _kMuted),
                        prefixIcon:
                            const Icon(Icons.search, size: 18, color: _kMuted),
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _kBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _kBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _kPrimary.withValues(alpha: 0.6),
                              width: 1.5),
                        ),
                      ),
                      onSubmitted: notifier.setSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 16),
                    label: const Text('Filters'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kBodyText,
                      side: const BorderSide(color: _kBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 40,
                  child: FilledButton.icon(
                    onPressed: () => context.push(Routes.addUser),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add a client'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (state.error != null) ...[
              const SizedBox(height: 10),
              Text(state.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            // Table card
            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: _kBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Table header row
                    Container(
                      height: 46,
                      color: _kTableHeaderBg,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _HeaderCell('Name'),
                          ),
                          Expanded(
                            flex: 3,
                            child: _HeaderCell('Email'),
                          ),
                          Expanded(
                            flex: 2,
                            child: _HeaderCell('Role'),
                          ),
                          Expanded(
                            flex: 2,
                            child: _HeaderCell('Joined'),
                          ),
                          SizedBox(
                            width: 88,
                            child: _HeaderCell('Actions'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: _kBorder),
                    // Table body
                    Expanded(
                      child: state.loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: _kPrimary,
                              ),
                            )
                          : state.users.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No clients found',
                                    style: TextStyle(color: _kMuted),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: state.users.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 1,
                                    color: _kBorder,
                                  ),
                                  itemBuilder: (_, i) => _ClientRow(
                                    user: state.users[i],
                                    onEdit: () => context.push(
                                        Routes.editUser,
                                        extra: state.users[i]),
                                    onDelete: () =>
                                        _confirmDelete(state.users[i]),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
            // Pagination bar
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.total} client${state.total == 1 ? '' : 's'} total',
                    style: const TextStyle(fontSize: 13, color: _kMuted),
                  ),
                  _Pagination(state: state, notifier: notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Table header cell ────────────────────────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _kTitleColor,
      ),
    );
  }
}

// ── Client row ───────────────────────────────────────────────────────────────

class _ClientRow extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientRow({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  String get _joinedDate {
    if (user.createdAt == null) return '—';
    final d = user.createdAt!;
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Name + avatar
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: _kPrimary.withValues(alpha: 0.14),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _kTitleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Email
          Expanded(
            flex: 3,
            child: Text(
              user.email,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: _kBodyText),
            ),
          ),
          // Role badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? _kPrimary.withValues(alpha: 0.12)
                      : _kGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAdmin ? 'Admin' : 'Client',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isAdmin ? _kPrimary : _kGreenText,
                  ),
                ),
              ),
            ),
          ),
          // Joined date
          Expanded(
            flex: 2,
            child: Text(
              _joinedDate,
              style: const TextStyle(fontSize: 13, color: _kBodyText),
            ),
          ),
          // Actions
          SizedBox(
            width: 88,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  color: _kPrimary,
                  tooltip: 'Edit',
                  onPressed: onEdit,
                ),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  color: Colors.red.shade400,
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      color: color,
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(6),
        minimumSize: const Size(32, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// ── Pagination ────────────────────────────────────────────────────────────────

class _Pagination extends StatelessWidget {
  final UserListState state;
  final UserListNotifier notifier;

  const _Pagination({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final pages = state.pages;
    final current = state.page;

    // Build the visible page numbers: always show first, last, current ± 1
    final Set<int> show = {1, pages};
    for (int p = current - 1; p <= current + 1; p++) {
      if (p >= 1 && p <= pages) show.add(p);
    }
    final sorted = show.toList()..sort();

    final items = <Widget>[];
    int? prev;
    for (final p in sorted) {
      if (prev != null && p - prev > 1) {
        items.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text('...', style: TextStyle(color: _kMuted, fontSize: 13)),
        ));
      }
      items.add(_PageBtn(
        label: '$p',
        isActive: p == current,
        onPressed: () => notifier.goToPage(p),
      ));
      prev = p;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PageBtn(
          icon: Icons.chevron_left,
          onPressed: current > 1 ? notifier.prevPage : null,
        ),
        ...items,
        _PageBtn(
          icon: Icons.chevron_right,
          onPressed: current < pages ? notifier.nextPage : null,
        ),
      ],
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback? onPressed;

  const _PageBtn({
    this.label,
    this.icon,
    this.isActive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 30,
        height: 30,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: isActive ? _kPrimary : Colors.transparent,
            foregroundColor: isActive
                ? Colors.white
                : (onPressed != null ? _kBodyText : _kMuted),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: EdgeInsets.zero,
          ),
          child: icon != null
              ? Icon(icon, size: 18)
              : Text(label ?? '',
                  style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
