import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../models/qualification_model.dart';
import '../core/constants/app_theme.dart';

/// White card with a round icon, title and description.
class FeatureCard extends StatelessWidget {
  final Feature feature;
  final bool centered;

  const FeatureCard({super.key, required this.feature, this.centered = true});

  @override
  Widget build(BuildContext context) {
    final cross =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: cross,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: AppColors.gold, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            feature.title,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  color: AppColors.darkNavy,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

/// Program / qualification card with gradient header and feature checklist.
class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: course.gold
                  ? AppColors.goldCardGradient
                  : AppColors.blueCardGradient,
            ),
            alignment: Alignment.center,
            child: Icon(
              course.gold ? Icons.emoji_events_outlined : Icons.school_outlined,
              color: Colors.white.withValues(alpha: 0.9),
              size: 44,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: AppColors.darkNavy,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  course.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkText,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Course Features:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 10),
                ...course.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 18, color: AppColors.royalBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin-managed Cambridge Qualification card — image header (falls back to
/// the gradient + icon treatment used by [CourseCard] when no image is set).
class QualificationCard extends StatelessWidget {
  final QualificationModel qualification;
  final VoidCallback? onLearnMore;

  const QualificationCard({super.key, required this.qualification, this.onLearnMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: qualification.gold ? AppColors.goldCardGradient : AppColors.blueCardGradient,
            ),
            alignment: Alignment.center,
            child: qualification.image != null
                ? CachedNetworkImage(
                    imageUrl: qualification.image!,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Icon(
                      qualification.gold ? Icons.emoji_events_outlined : Icons.school_outlined,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 44,
                    ),
                  )
                : Icon(
                    qualification.gold ? Icons.emoji_events_outlined : Icons.school_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 44,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qualification.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 10),
                Text(
                  qualification.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkText, height: 1.5),
                ),
                if (qualification.features.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Course Features:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkNavy)),
                  const SizedBox(height: 10),
                  ...qualification.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 18, color: AppColors.royalBlue),
                          const SizedBox(width: 8),
                          Expanded(child: Text(f, style: const TextStyle(fontSize: 14, color: AppColors.darkText))),
                        ],
                      ),
                    ),
                  ),
                ],
                if (onLearnMore != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onLearnMore,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Learn More', style: TextStyle(color: AppColors.royalBlue, fontWeight: FontWeight.w600)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 16, color: AppColors.royalBlue),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

