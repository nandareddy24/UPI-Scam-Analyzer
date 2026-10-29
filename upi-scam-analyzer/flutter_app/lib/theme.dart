import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color cardDark = Color(0xFF151D2A);
  static const Color cardBorder = Color(0xFF1E293B);
  static const Color primary = Color(0xFF10B981); // Vibrant Emerald
  static const Color primaryDark = Color(0xFF059669);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color safe = Color(0xFF10B981);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData get theme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentCyan,
        surface: cardDark,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF0F172A),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

