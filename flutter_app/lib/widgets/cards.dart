import 'package:flutter/material.dart';
import '../models/models.dart';
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

/// Testimonial card with star rating and quote.
class TestimonialCard extends StatelessWidget {
  final Testimonial testimonial;

  const TestimonialCard({super.key, required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              testimonial.rating,
              (_) => const Icon(Icons.star, size: 20, color: AppColors.gold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${testimonial.review}"',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.darkText,
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.royalBlue.withValues(alpha: 0.12),
                child: const Icon(Icons.person, color: AppColors.royalBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      testimonial.role,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
