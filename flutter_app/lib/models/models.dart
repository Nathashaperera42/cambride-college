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

