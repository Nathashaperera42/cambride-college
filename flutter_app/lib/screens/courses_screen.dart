import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';
import '../core/network/api_exception.dart';
import '../models/course_api_model.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../providers/course_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/route_names.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import '../widgets/auth_modal.dart';

class CoursesPage extends ConsumerStatefulWidget {
  const CoursesPage({super.key});

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseProvider.notifier).loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseProvider);

    return Column(
      children: [
        const PageBanner(
          title: 'Cambridge English Courses',
          subtitle:
              'Build confidence through internationally recognized English qualifications.',
        ),

        // ── Cambridge qualifications ─────────────────────────────────────────
        Container(
          width: double.infinity,
          color: AppColors.white,
          child: ContentWrap(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: Column(
              children: [
                const SectionTitle(
                  title: 'Cambridge English Qualifications',
                  subtitle:
                      'A complete pathway from young learners to advanced professional certifications.',
                ),
                const SizedBox(height: 40),
                if (courseState.loading)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  )
                else if (courseState.courses.isNotEmpty)
                  ...courseState.courses.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _ApiCourseCard(course: c),
                    ),
                  )
                else
                  ...AppData.programs.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _StaticCourseCard(course: c),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Courses we offer ─────────────────────────────────────────────────
        Container(
          width: double.infinity,
          color: AppColors.lightBlueBg,
          child: ContentWrap(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: Column(
              children: [
                const SectionTitle(
                  title: 'Courses We Offer',
                  subtitle:
                      'General communication courses for every age and goal.',
                ),
                const SizedBox(height: 40),
                ResponsiveGrid(
                  columnsFor: (w) =>
                      w >= 1000 ? 5 : (w >= 700 ? 3 : (w >= 460 ? 2 : 1)),
                  children: AppData.offeredCourses
                      .map((f) => FeatureCard(feature: f))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared card banner layout ─────────────────────────────────────────────────

class _CardBanner extends StatelessWidget {
  final String title;
  final String? level;
  final String? ageGroup;
  final String? duration;
  final bool gold;

  const _CardBanner({
    required this.title,
    this.level,
    this.ageGroup,
    this.duration,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: gold
            ? const LinearGradient(
                colors: [Color(0xFF8B6914), Color(0xFFD4A01A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF083B7A), Color(0xFF0D5CBF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + level badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (level != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      level!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Age group + duration
          if (ageGroup != null || duration != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (ageGroup != null)
                  Text(
                    'Age Group: $ageGroup',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                if (duration != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Duration: $duration',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

// ── Shared section header (icon + title) ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.royalBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.royalBlue,
          ),
        ),
      ],
    );
  }
}

// ── Feature bullet with optional bold label before colon ─────────────────────

Widget _featureBullet(String text) {
  final colonIdx = text.indexOf(':');
  if (colonIdx > 0 && colonIdx < 26) {
    final label = text.substring(0, colonIdx);
    final rest = text.substring(colonIdx + 1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 13, color: AppColors.darkText, height: 1.5),
                children: [
                  TextSpan(
                      text: '$label:',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1D3D))),
                  TextSpan(text: rest),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ',
            style: TextStyle(
                color: AppColors.royalBlue,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.darkText, height: 1.5)),
        ),
      ],
    ),
  );
}

// ── API-backed course card ────────────────────────────────────────────────────

class _ApiCourseCard extends ConsumerWidget {
  final CourseApiModel course;
  const _ApiCourseCard({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final inCart = ref.watch(
        cartProvider.select((c) => c.any((i) => i.course.id == course.id)));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner header
          _CardBanner(
            title: course.title,
            level: course.level,
            ageGroup: course.ageGroup,
            duration: course.duration,
            gold: course.gold,
          ),

          // Content area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(builder: (ctx, constraints) {
                  final description =
                      course.shortDescription ?? course.description;
                  final wide = constraints.maxWidth >= 480;

                  final focusCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        icon: Icons.track_changes_outlined,
                        title: 'Course Focus',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkText,
                            height: 1.6),
                      ),
                    ],
                  );

                  if (course.features.isEmpty) return focusCol;

                  final skillsCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Skills & Activities',
                      ),
                      const SizedBox(height: 10),
                      ...course.features.map(_featureBullet),
                    ],
                  );

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: focusCol),
                        const SizedBox(width: 24),
                        Expanded(child: skillsCol),
                      ],
                    );
                  }
                  return Column(children: [
                    focusCol,
                    const SizedBox(height: 16),
                    skillsCol,
                  ]);
                }),

                const SizedBox(height: 20),
                _CourseRatingRow(course: course),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),

                // Price + buttons footer
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Rs. ${course.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.royalBlue,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            if (inCart) {
                              context.go(Routes.cart);
                            } else {
                              cartNotifier.addCourse(course);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart!'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: AppColors.royalBlue,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                              inCart
                                  ? Icons.shopping_cart
                                  : Icons.add_shopping_cart,
                              size: 16),
                          label: Text(inCart ? 'In Cart' : 'Add to Cart',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.royalBlue,
                            side: const BorderSide(color: AppColors.royalBlue),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _enrollNow(context, ref, course),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Enroll Now',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _enrollNow(
      BuildContext context, WidgetRef ref, CourseApiModel course) {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      showLoginModal(context);
      return;
    }
    ref.read(cartProvider.notifier).addCourse(course);
    context.go(Routes.checkout);
  }
}

// ── Rating summary + "Rate this course" action ───────────────────────────────

class _CourseRatingRow extends ConsumerWidget {
  final CourseApiModel course;
  const _CourseRatingRow({required this.course});

  Future<void> _rateCourse(BuildContext context, WidgetRef ref) async {
    if (ref.read(authProvider).status != AuthStatus.authenticated) {
      showLoginModal(context);
      return;
    }
    final confirmation = await showDialog<String>(
      context: context,
      builder: (_) => _CourseReviewDialog(courseId: course.id),
    );
    if (confirmation == null || !context.mounted) return;
    ref.read(courseProvider.notifier).loadCourses();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(confirmation),
      backgroundColor: AppColors.royalBlue,
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReviews = course.reviewCount > 0;
    return Row(
      children: [
        Row(
          children: List.generate(5, (i) {
            final filled = i < course.avgRating.round();
            return Icon(filled ? Icons.star : Icons.star_border, size: 16, color: AppColors.gold);
          }),
        ),
        const SizedBox(width: 8),
        Text(
          hasReviews ? '${course.avgRating.toStringAsFixed(1)} (${course.reviewCount})' : 'No reviews yet',
          style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _rateCourse(context, ref),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
          child: const Text('Rate this course', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _CourseReviewDialog extends ConsumerStatefulWidget {
  final String courseId;
  const _CourseReviewDialog({required this.courseId});

  @override
  ConsumerState<_CourseReviewDialog> createState() => _CourseReviewDialogState();
}

class _CourseReviewDialogState extends ConsumerState<_CourseReviewDialog> {
  final _messageCtrl = TextEditingController();
  int _rating = 5;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final (_, confirmation) = await ref.read(courseReviewRepositoryProvider).create(
            courseId: widget.courseId,
            rating: _rating,
            message: _messageCtrl.text.trim(),
          );
      if (mounted) Navigator.pop(context, confirmation);
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
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rate this Course',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
              const SizedBox(height: 18),
              Row(
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return IconButton(
                    onPressed: () => setState(() => _rating = i + 1),
                    icon: Icon(filled ? Icons.star : Icons.star_border, color: AppColors.gold, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  );
                }),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _messageCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comments (optional)',
                  border: OutlineInputBorder(),
                ),
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
                        : const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Static fallback card (shown when API unavailable) ────────────────────────

class _StaticCourseCard extends StatelessWidget {
  final Course course;
  const _StaticCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner header
          _CardBanner(
            title: course.title,
            level: course.level,
            ageGroup: course.ageGroup,
            duration: course.duration,
            gold: course.gold,
          ),

          // Content area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(builder: (ctx, constraints) {
                  final description =
                      course.shortDescription ?? course.description;
                  final wide = constraints.maxWidth >= 480;

                  final focusCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        icon: Icons.track_changes_outlined,
                        title: 'Course Focus',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkText,
                            height: 1.6),
                      ),
                    ],
                  );

                  if (course.features.isEmpty) return focusCol;

                  final skillsCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Skills & Activities',
                      ),
                      const SizedBox(height: 10),
                      ...course.features.map(_featureBullet),
                    ],
                  );

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: focusCol),
                        const SizedBox(width: 24),
                        Expanded(child: skillsCol),
                      ],
                    );
                  }
                  return Column(children: [
                    focusCol,
                    const SizedBox(height: 16),
                    skillsCol,
                  ]);
                }),

                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),

                // Price + buttons footer
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (course.price != null)
                      Text(
                        'Rs. ${course.price!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.royalBlue,
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Create an account to add courses to your cart!'),
                                backgroundColor: AppColors.royalBlue,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Add to Cart',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.royalBlue,
                            side: const BorderSide(color: AppColors.royalBlue),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Call us at +94 76 1229238 to enroll today!'),
                                backgroundColor: AppColors.gold,
                                duration: const Duration(seconds: 4),
                                action: SnackBarAction(
                                  label: 'OK',
                                  textColor: Colors.white,
                                  onPressed: () {},
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Enroll Now',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
