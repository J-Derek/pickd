import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme derived from Figma Integration Plan — OLED & Neon
class AppTheme {
  // ─── Colors ──────────────────────────────────────────────────
  static const bgPrimary = Color(0xFF0A0A0F); // OLED Black
  static const bgSurface = Color(0xFF13131A); // Slightly lighter for cards
  static const bgElevated = Color(0xFF1C1C26);
  static const bgMuted = Color(0xFF252530);

  static const accentPrimary = Color(0xFF6B4EFF); // Neon Indigo/Purple
  static const accentGlow = Color(0x666B4EFF);
  static const accentSecondary = Color(0xFF00F0FF); // Electric Cyan
  static const accentGreen = Color(0xFF00F0FF); // Swap green for cyan

  static const gemsColor = Color(0xFFFFC107); // Bright Yellow/Gold
  static const errorColor = Color(0xFFFF4081); // Neon Pink
  static const destructiveRed = Color(0xFFFF4444); // Destructive Red

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0C0);
  static const textMuted = Color(0xFF6B6B80);
  static const textInverse = Color(0xFF0A0A0F);

  // ─── Gradients ────────────────────────────────────────────────
  static const cardBottomGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4, 1.0],
    colors: [Colors.transparent, Colors.transparent, bgPrimary],
  );

  static const gemsBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4081), gemsColor], // Pink to Yellow
  );

  // ─── Shadows & Glass ──────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.8),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> cardDraggingShadow = [
    BoxShadow(
      color: accentPrimary.withValues(alpha: 0.3),
      blurRadius: 40,
      spreadRadius: 8,
      offset: const Offset(0, 16),
    ),
  ];

  // Glassmorphism background color
  static Color get glassBackground => const Color(0xFF13131A).withValues(alpha: 0.6);
  // Glassmorphism border color
  static Color get glassBorder => Colors.white.withValues(alpha: 0.1);
  // Glassmorphism blur sigma
  static const double glassBlur = 24.0;

  // ─── Theme ────────────────────────────────────────────────────
  static ThemeData get theme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: bgSurface,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        error: errorColor,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgPrimary,
        selectedItemColor: accentPrimary,
        unselectedItemColor: textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: textPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: BorderSide(color: glassBorder, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgElevated,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: glassBorder, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: glassBorder, width: 1),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.15,
        letterSpacing: -1.0,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: textSecondary,
        letterSpacing: 0.2,
      ),
    );
  }
}
