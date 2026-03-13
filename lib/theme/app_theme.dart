import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00E5FF);
  static const Color backgroundDark = Color(0xFF0A1619);
  static const Color backgroundLight = Color(0xFFF5FBFB);

  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.spaceGrotesk(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.015),
    displayMedium: GoogleFonts.spaceGrotesk(fontSize: 45, fontWeight: FontWeight.bold, letterSpacing: -0.015),
    displaySmall: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -0.015),
    headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.25),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      surface: backgroundDark,
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _appTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: _appTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ),
    iconTheme: const IconThemeData(color: primaryColor),
  );
}
