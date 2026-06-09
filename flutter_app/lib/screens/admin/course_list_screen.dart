import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/course_provider.dart';
import '../../models/course_api_model.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseProvider.notifier).loadAdminCourses();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseProvider);

    return AdminShell(
      activeRoute: Routes.adminCourses,
      breadcrumbs: const ['Admin', 'Courses'],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search courses…',
                      prefixIcon: const Icon(Icons.search, size: 20, color: _kMutedColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
                      filled: true, fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) => ref.read(courseProvider.notifier).loadAdminCourses(search: v),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push(Routes.addCourse),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Course', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.error != null)
              Expanded(child: Center(child: Text(state.error!, style: const TextStyle(color: Colors.red))))
            else if (state.courses.isEmpty)
              const Expanded(child: Center(child: Text('No courses yet. Click "Add Course" to create one.', style: TextStyle(color: _kMutedColor))))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: state.courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CourseRow(
                    course: state.courses[i],
                    onEdit: () => context.push(Routes.editCourse, extra: state.courses[i]),
                    onDelete: () => _confirmDelete(context, ref, state.courses[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, CourseApiModel course) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Course', style: TextStyle(color: _kTitleColor, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${course.title}"? This cannot be undone.'),
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
    if (ok == true && mounted) {
      final ok2 = await ref.read(courseProvider.notifier).deleteCourse(course.id);
      messenger.showSnackBar(SnackBar(
        content: Text(ok2 ? 'Course deleted.' : 'Failed to delete course.'),
        backgroundColor: ok2 ? Colors.green : Colors.red,
      ));
    }
  }
}

class _CourseRow extends StatelessWidget {
  final CourseApiModel course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _CourseRow({required this.course, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: _kBorderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final narrow = constraints.maxWidth < 420;

            final thumbnail = ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: course.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnail!,
                      width: 64,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _thumb(course.gold))
                  : _thumb(course.gold),
            );

            final titleCol = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _kTitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(course.category,
                    style: const TextStyle(
                        fontSize: 12, color: _kMutedColor)),
              ],
            );

            final priceText = Text(
              'Rs. ${course.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _kPrimary,
                  fontSize: 15),
            );

            final statusBadge = Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: course.isPublished
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                course.isPublished ? 'Published' : 'Draft',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: course.isPublished
                        ? const Color(0xFF166534)
                        : _kMutedColor),
              ),
            );

            final editBtn = IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: _kPrimary),
                onPressed: onEdit,
                tooltip: 'Edit');
            final deleteBtn = IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Delete');

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    thumbnail,
                    const SizedBox(width: 12),
                    Expanded(child: titleCol),
                    editBtn,
                    deleteBtn,
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    priceText,
                    const SizedBox(width: 8),
                    statusBadge,
                  ]),
                ],
              );
            }

            return Row(children: [
              thumbnail,
              const SizedBox(width: 14),
              Expanded(child: titleCol),
              const SizedBox(width: 12),
              priceText,
              const SizedBox(width: 8),
              statusBadge,
              const SizedBox(width: 4),
              editBtn,
              deleteBtn,
            ]);
          },
        ),
      ),
    );
  }

  Widget _thumb(bool gold) => Container(
    width: 64, height: 56,
    decoration: BoxDecoration(gradient: gold ? AppColors.goldCardGradient : AppColors.blueCardGradient),
    child: Icon(gold ? Icons.emoji_events_outlined : Icons.school_outlined, color: Colors.white54, size: 26),
  );
}
