import 'package:flutter/material.dart';

/// A small highlight/feature shown in card grids.
class Feature {
  final IconData icon;
  final String title;
  final String description;

  const Feature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// A Cambridge qualification / program card.
class Course {
  final String title;
  final String description;
  final String? shortDescription;
  final List<String> features;
  final bool gold;
  final String? level;
  final String? ageGroup;
  final String? duration;
  final double? price;
  final String? category;

  const Course({
    required this.title,
    required this.description,
    this.shortDescription,
    required this.features,
    this.gold = false,
    this.level,
    this.ageGroup,
    this.duration,
    this.price,
    this.category,
  });
}

/// A parent/student testimonial.
class Testimonial {
  final String name;
  final String role;
  final int rating;
  final String review;

  const Testimonial({
    required this.name,
    required this.role,
    required this.rating,
    required this.review,
  });
}

/// A statistic counter (e.g. "2500+ Students").
class StatItem {
  final String value;
  final String label;
  final IconData? icon;

  const StatItem({required this.value, required this.label, this.icon});
}

/// A navigation destination for the header.
class NavItem {
  final String label;
  final int index;
  const NavItem(this.label, this.index);
}

/// A website section image managed by the admin.
class SiteImage {
  final String id;
  final String section;
  final String label;
  final String imageUrl;
  final String publicId;
  final String altText;
  final int order;
  final bool isActive;

  const SiteImage({
    required this.id,
    required this.section,
    required this.label,
    required this.imageUrl,
    required this.publicId,
    required this.altText,
    required this.order,
    required this.isActive,
  });

  factory SiteImage.fromJson(Map<String, dynamic> json) => SiteImage(
        id: json['_id'] as String,
        section: json['section'] as String,
        label: json['label'] as String,
        imageUrl: json['imageUrl'] as String,
        publicId: json['publicId'] as String? ?? '',
        altText: json['altText'] as String? ?? '',
        order: (json['order'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );

  SiteImage copyWith({
    String? label,
    String? altText,
    int? order,
    bool? isActive,
    String? imageUrl,
  }) =>
      SiteImage(
        id: id,
        section: section,
        label: label ?? this.label,
        imageUrl: imageUrl ?? this.imageUrl,
        publicId: publicId,
        altText: altText ?? this.altText,
        order: order ?? this.order,
        isActive: isActive ?? this.isActive,
      );
}
