import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme derived from DESIGN.md — Dark Cinematic palette
class AppTheme {
  // ─── Colors ──────────────────────────────────────────────────
  static const bgPrimary = Color(0xFF0E1417);
  static const bgSurface = Color(0xFF161D1F);
  static const bgElevated = Color(0xFF1A2123);
  static const bgMuted = Color(0xFF2F3639);

  static const accentPrimary = Color(0xFF00D1FF);
  static const accentGlow = Color(0x4000D1FF);
  static const accentSecondary = Color(0xFF00566A);
  static const accentGreen = Color(0xFF4CAF88);

  static const textPrimary = Color(0xFFDDE3E7);
  static const textSecondary = Color(0xFFBBC9CF);
  static const textMuted = Color(0xFF859399);
  static const textInverse = Color(0xFF00566A);

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
    colors: [Color(0xFF7B2FBE), accentPrimary],
  );

  // ─── Shadows & Glass ──────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> cardDraggingShadow = [
    BoxShadow(
      color: accentPrimary.withValues(alpha: 0.2),
      blurRadius: 40,
      spreadRadius: 4,
      offset: const Offset(0, 16),
    ),
  ];


  // Glassmorphism background color
  static Color get glassBackground => const Color(0xFF161D1F).withValues(alpha: 0.4);
  // Glassmorphism border color
  static Color get glassBorder => Colors.white.withValues(alpha: 0.05);
  // Glassmorphism blur sigma
  static const double glassBlur = 32.0;

  // ─── Theme ────────────────────────────────────────────────────
  static ThemeData get theme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: bgSurface,
        onPrimary: textInverse,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Syne',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgElevated,
        selectedItemColor: accentPrimary,
        unselectedItemColor: textMuted,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: textInverse,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        side: BorderSide.none,
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
      // Display — Syne 800
      displayLarge: GoogleFonts.syne(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.15,
      ),
      // Heading — Syne 700
      headlineLarge: GoogleFonts.syne(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),
      // Title — Syne 700
      titleLarge: GoogleFonts.syne(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.syne(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // Body — Inter
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
      // Caption
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
