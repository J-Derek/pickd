import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme derived from DESIGN.md — Dark Cinematic palette
class AppTheme {
  // ─── Colors ──────────────────────────────────────────────────
  static const bgPrimary = Color(0xFF0A0A0F);
  static const bgSurface = Color(0xFF131318);
  static const bgElevated = Color(0xFF1C1C24);
  static const bgMuted = Color(0xFF252530);

  static const accentPrimary = Color(0xFFF5A623);
  static const accentGlow = Color(0x40F5A623);
  static const accentSecondary = Color(0xFFFF6B6B);
  static const accentGreen = Color(0xFF4CAF88);

  static const textPrimary = Color(0xFFF2F2F5);
  static const textSecondary = Color(0xFF9999AA);
  static const textMuted = Color(0xFF55556A);
  static const textInverse = Color(0xFF0A0A0F);

  // ─── Gradients ────────────────────────────────────────────────
  static const cardBottomGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.35, 1.0],
    colors: [Colors.transparent, Colors.transparent, bgPrimary],
  );

  static const gemsBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B2FBE), accentPrimary],
  );

  // ─── Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> cardDraggingShadow = [
    BoxShadow(
      color: accentPrimary.withOpacity(0.15),
      blurRadius: 32,
      spreadRadius: 2,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> amberGlow = [
    BoxShadow(
      color: accentPrimary.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 1,
    ),
  ];

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
          fontSize: 20,
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
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.08),
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        letterSpacing: 0.8,
      ),
    );
  }
}
