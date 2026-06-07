import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color palette taken directly from the site's theme.css
/// (Cambridge color scheme used in the reference design).
class AppColors {
  AppColors._();

  static const Color royalBlue = Color(0xFF0B4DA2);
  static const Color darkNavy = Color(0xFF083B7A);
  static const Color gold = Color(0xFFE8B21D);
  static const Color goldDark = Color(0xFFD4A01A);
  static const Color lightBlueBg = Color(0xFFF4F8FF);
  static const Color lightGray = Color(0xFFF7F7F7);
  static const Color darkText = Color(0xFF1F2937);
  static const Color mutedText = Color(0xFF6B7280);
  static const Color footerBg = Color(0xFF1A2332);
  static const Color footerLink = Color(0xFF4A9FF5);
  static const Color white = Color(0xFFFFFFFF);

  /// Hero / banner gradient (dark navy → royal blue).
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [darkNavy, royalBlue],
  );

  /// Gold CTA gradient.
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gold, goldDark],
  );

  /// Card header gradients used on the program cards.
  static const LinearGradient blueCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royalBlue, darkNavy],
  );

  static const LinearGradient goldCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldDark],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    // Inter for body, Poppins for headings (matches --font-heading / --font-body).
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.darkNavy,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.darkNavy,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.darkNavy,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkNavy,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.darkText),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.darkText),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      primaryColor: AppColors.royalBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.royalBlue,
        secondary: AppColors.gold,
        surface: AppColors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}

/// Convenience: max content width used to centre content on wide screens.
const double kMaxContentWidth = 1200;

/// Simple responsive helpers.
class Responsive {
  static bool isMobile(BuildContext c) => MediaQuery.of(c).size.width < 760;
  static bool isTablet(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    return w >= 760 && w < 1100;
  }

  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= 1100;
}
