import 'package:flutter/material.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';

/// Logo lockup: circular emblem + "Governess College / of English / tagline".
class BrandLogo extends StatelessWidget {
  final bool onDark;
  final bool showTagline;

  const BrandLogo({super.key, this.onDark = false, this.showTagline = true});

  @override
  Widget build(BuildContext context) {
    final Color primary = onDark ? Colors.white : AppColors.darkNavy;
    final Color secondary = onDark ? AppColors.gold : AppColors.gold;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 2),
            color: onDark ? Colors.white : AppColors.lightBlueBg,
          ),
          child: const Icon(Icons.auto_awesome, size: 20, color: AppColors.gold),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppData.brandName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.1,
                color: primary,
              ),
            ),
            Text(
              AppData.brandSub,
              style: TextStyle(
                fontSize: 13,
                color: onDark ? Colors.white70 : AppColors.royalBlue,
                height: 1.1,
              ),
            ),
            if (showTagline)
              Text(
                AppData.tagline,
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: secondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
