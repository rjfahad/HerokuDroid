import 'package:flutter/material.dart';

/// Design B (Paper) spacing, radius and typography tokens.
class PaperTokens {
  PaperTokens._();

  // Spacing
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;

  // Radius
  static const double rInput = 14;
  static const double rCard = 20;
  static const double rSheet = 22;
  static const double rHero = 26;
  static const double rPill = 99;
}

/// Paper typography. Headings use a serif family to match the mockup;
/// body copy stays on the platform UI font.
class PaperText {
  PaperText._();

  static const String _serif = 'serif';
  static const List<String> _serifFallback = [
    'Georgia',
    'Times New Roman',
  ];

  /// Oversized marketing heading (login hero).
  static const TextStyle hero = TextStyle(
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 42,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  /// Small uppercase section label (`.cap`).
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body = TextStyle(fontSize: 14, height: 1.45);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, height: 1.45);

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    height: 1.5,
  );
}
