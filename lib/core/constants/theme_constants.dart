import 'package:flutter/material.dart';

/// Theme constants and color palette
class ThemeConstants {
  // Private constructor to prevent instantiation
  ThemeConstants._();

  /// Modern primary colors - Sleek blue-gray palette
  static const Color primaryBlue = Color(0xFF0F172A); // Slate 900 - Deep navy
  static const Color primaryAccent = Color(
    0xFF3B82F6,
  ); // Blue 500 - Vibrant blue
  static const Color secondaryAccent = Color(
    0xFF06B6D4,
  ); // Cyan 500 - Bright cyan

  /// Status colors - Modern and subtle
  static const Color statusSuccess = Color(0xFF10B981); // Emerald 500
  static const Color statusWarning = Color(0xFFF59E0B); // Amber 500
  static const Color statusError = Color(0xFFEF4444); // Red 500
  static const Color statusInfo = Color(0xFF3B82F6); // Blue 500

  /// Log level colors - Distinct and readable
  static const Color logInfo = Color(0xFF60A5FA); // Blue 400
  static const Color logWarning = Color(0xFFFBBF24); // Amber 400
  static const Color logError = Color(0xFFF87171); // Red 400
  static const Color logDebug = Color(0xFF94A3B8); // Slate 400

  /// Background colors - Clean and modern
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color cardLight = Color(0xFFFFFFFF); // Pure white
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceLight = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceDark = Color(0xFF334155); // Slate 700

  /// Text colors - High contrast
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textHint = Color(0xFF94A3B8); // Slate 400

  /// Border and divider colors - Subtle
  static const Color dividerColor = Color(0xFFE2E8F0); // Slate 200
  static const Color borderColor = Color(0xFFCBD5E1); // Slate 300

  /// Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryAccent,
      brightness: Brightness.light,
      primary: primaryAccent,
      secondary: secondaryAccent,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    appBarTheme: AppBarTheme(
      backgroundColor: cardLight,
      foregroundColor: primaryBlue,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryBlue,
      ),
      iconTheme: const IconThemeData(color: primaryBlue, size: 22),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryAccent,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryAccent, width: 2),
      ),
      filled: true,
      fillColor: cardLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: dividerColor, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  /// Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryAccent,
      brightness: Brightness.dark,
      primary: primaryAccent,
      secondary: secondaryAccent,
      surface: cardDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    appBarTheme: AppBarTheme(
      backgroundColor: cardDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 22),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryAccent,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: surfaceDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: surfaceDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryAccent, width: 2),
      ),
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: surfaceDark, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: surfaceDark,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  /// Text styles - Compact and modern
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  /// Monospace font for logs - More compact
  static const TextStyle monospaceMedium = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    height: 1.4,
  );

  static const TextStyle monospaceSmall = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    height: 1.4,
  );

  /// Spacing - More compact
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 24.0;

  /// Border radius - Consistent rounded corners
  static const double radiusS = 6.0;
  static const double radiusM = 10.0;
  static const double radiusL = 12.0;
  static const double radiusXl = 16.0;

  /// Icon sizes - Compact
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXl = 32.0;
}
