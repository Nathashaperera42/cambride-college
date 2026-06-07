import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../models/course_api_model.dart';
import '../../routes/route_names.dart';

class MyCoursesScreen extends ConsumerStatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  ConsumerState<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends ConsumerState<MyCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).loadMyCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: AppColors.darkNavy, onPressed: () => context.go(Routes.home)),
        title: const Text('My Courses', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.myCourses.isEmpty
              ? _empty(context)
              : LayoutBuilder(
                builder: (context, constraints) => GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth >= 700 ? 2 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: state.myCourses.length,
                  itemBuilder: (_, i) => _CourseCard(course: state.myCourses[i]),
                ),
              ),
    );
  }

  Widget _empty(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.menu_book_outlined, size: 72, color: AppColors.mutedText),
      const SizedBox(height: 16),
      const Text('No courses yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
      const SizedBox(height: 8),
      const Text('Enroll in a course to access it here.', style: TextStyle(color: AppColors.mutedText)),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => context.go(Routes.home),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royalBlue, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Browse Courses', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}

class _CourseCard extends StatelessWidget {
  final CourseApiModel course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: course.thumbnail != null
                ? CachedNetworkImage(imageUrl: course.thumbnail!, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _grad(course.gold))
                : _grad(course.gold),
          ),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)])))),
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(course.category, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              Text(course.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                child: const Text('Start Learning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _grad(bool gold) => Container(
    decoration: BoxDecoration(gradient: gold ? AppColors.goldCardGradient : AppColors.blueCardGradient),
  );
}
