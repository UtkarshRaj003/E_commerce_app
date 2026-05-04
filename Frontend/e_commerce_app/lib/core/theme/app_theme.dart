import 'package:flutter/material.dart';
import '../../../../common/widgets/common_widgets.dart';

// AppTheme defines the full Material 3 theme for both light and dark modes.
// Light mode uses a premium cool-white/slate palette (AppColors.light*).
// Dark mode uses deep-space dark backgrounds (AppColors.deepSpace family).
// Neon cyan/purple accents are the brand identity — same in both themes.
class AppTheme {
  // ── Light Theme ─────────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Scaffold and surface colors
    scaffoldBackgroundColor: AppColors.lightBg,
    canvasColor: AppColors.lightBg,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.neonCyan,
      brightness: Brightness.light,
      background: AppColors.lightBg,
      surface: AppColors.lightCard,
      onBackground: AppColors.lightTextPrimary,
      onSurface: AppColors.lightTextPrimary,
      primary: AppColors.neonCyan,
      secondary: AppColors.neonPurple,
    ),

    // AppBar — transparent so glass blur shows through
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.lightTextPrimary,
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
    ),

    // Card — white with subtle shadow
    cardTheme: CardTheme(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),

    // Input fields — light fill with slate border
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCardAlt,
      hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Elevated button — neon cyan gradient (same as dark for brand consistency)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),

    // Text — dark navy for readability on light backgrounds
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
      bodySmall: TextStyle(color: AppColors.lightTextSecondary),
      titleLarge: TextStyle(
          color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(
          color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
    ),

    // Divider
    dividerColor: AppColors.lightBorder,
    dividerTheme: const DividerThemeData(color: AppColors.lightBorder),

    // Switch — neon cyan active track
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? Colors.white : null),
      trackColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? AppColors.neonCyan : null),
    ),
  );

  // ── Dark Theme ──────────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Scaffold and surface colors
    scaffoldBackgroundColor: AppColors.deepSpace,
    canvasColor: AppColors.deepSpace,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.neonCyan,
      brightness: Brightness.dark,
      background: AppColors.deepSpace,
      surface: const Color(0xFF111827),
      onBackground: Colors.white,
      onSurface: Colors.white,
      primary: AppColors.neonCyan,
      secondary: AppColors.neonPurple,
    ),

    // AppBar — transparent so glass blur shows through
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white70),
    ),

    // Card — dark surface with subtle border
    cardTheme: CardTheme(
      color: const Color(0xFF111827),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
      ),
    ),

    // Input fields — glass fill with white border
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      hintStyle: TextStyle(color: Colors.white38),
      labelStyle: TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),

    // Text
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white54),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),

    // Divider
    dividerColor: Color(0xFF1F2937),
    dividerTheme: const DividerThemeData(color: Color(0xFF1F2937)),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? Colors.white : null),
      trackColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? AppColors.neonCyan : null),
    ),
  );
}
