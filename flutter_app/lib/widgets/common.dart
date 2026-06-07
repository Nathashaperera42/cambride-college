import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';

/// Centres content and constrains it to [kMaxContentWidth] with side padding.
class ContentWrap extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ContentWrap({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Section heading with optional subtitle, centered.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color titleColor;
  final Color subtitleColor;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.titleColor = AppColors.darkNavy,
    this.subtitleColor = AppColors.darkText,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: titleColor,
                fontSize: isMobile ? 28 : 40,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: subtitleColor,
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Lays out [children] in a grid that adapts column count to width.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int Function(double width) columnsFor;

  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.columnsFor,
    this.spacing = 24,
    this.runSpacing = 24,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = columnsFor(constraints.maxWidth).clamp(1, children.length);
        final totalSpacing = spacing * (cols - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }
}

/// Gradient banner shown at the top of inner pages.
class PageBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageBanner({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: ContentWrap(
        padding: EdgeInsets.symmetric(
            horizontal: 24, vertical: isMobile ? 48 : 72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: isMobile ? 32 : 46,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                subtitle,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 17, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped button used across the site.
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool gold;
  final bool outlinedWhite;
  final IconData? trailingIcon;

  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gold = false,
    this.outlinedWhite = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = gold
        ? AppColors.gold
        : (outlinedWhite ? Colors.transparent : AppColors.royalBlue);
    final Color fg = gold
        ? AppColors.darkText
        : (outlinedWhite ? Colors.white : Colors.white);

    return Material(
      color: bg,
      shape: StadiumBorder(
        side: outlinedWhite
            ? const BorderSide(color: Colors.white, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: 18, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
