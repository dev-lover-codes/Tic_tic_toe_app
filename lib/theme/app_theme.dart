import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF00E5FF);
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color accent = Color(0xFFA855F7);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color bgDark = Color(0xFF060E14);
  static const Color bgMid = Color(0xFF0A1619);
  static const Color bgCard = Color(0xFF0F2027);
  static const Color textPrimary = Color(0xFFECFEFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 52, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -1),
    displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 38, fontWeight: FontWeight.w700, color: textPrimary),
    headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
    headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
    titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
    titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
    bodyLarge: GoogleFonts.spaceGrotesk(fontSize: 16, color: textSecondary),
    bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 14, color: textSecondary),
    labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: textPrimary),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: bgMid,
      error: danger,
    ),
    scaffoldBackgroundColor: bgDark,
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _textTheme.titleLarge?.copyWith(letterSpacing: 2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      labelStyle: _textTheme.bodyMedium,
      hintStyle: GoogleFonts.spaceGrotesk(color: textSecondary.withValues(alpha: 0.5)),
      prefixIconColor: primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1),
        elevation: 8,
        shadowColor: primary.withValues(alpha: 0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    iconTheme: const IconThemeData(color: primary),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: bgCard,
      contentTextStyle: _textTheme.bodyMedium?.copyWith(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
