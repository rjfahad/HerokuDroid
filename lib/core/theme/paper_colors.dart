import 'package:flutter/material.dart';

/// Design B (Paper) color tokens.
///
/// Registered on [ThemeData.extensions] so every widget can resolve the
/// palette for the active brightness with `PaperColors.of(context)`.
@immutable
class PaperColors extends ThemeExtension<PaperColors> {
  /// Page / behind-the-device background.
  final Color page;

  /// Screen background.
  final Color background;

  /// Raised surfaces (cards, inputs, sheets).
  final Color card;

  /// Primary text.
  final Color ink;

  /// Secondary / caption text.
  final Color muted;

  /// Hairline borders and dividers.
  final Color line;

  /// Brand accent (violet).
  final Color accent;

  /// Tinted accent background.
  final Color accentSoft;

  final Color success;
  final Color successSoft;
  final Color error;
  final Color errorSoft;
  final Color warning;
  final Color warningSoft;

  /// Inverted surface used by hero panels and the log terminal.
  final Color contrast;
  final Color onContrast;

  const PaperColors({
    required this.page,
    required this.background,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.error,
    required this.errorSoft,
    required this.warning,
    required this.warningSoft,
    required this.contrast,
    required this.onContrast,
  });

  static const PaperColors light = PaperColors(
    page: Color(0xFFE7E1D5),
    background: Color(0xFFF6F2EA),
    card: Color(0xFFFFFDF8),
    ink: Color(0xFF1C1B19),
    muted: Color(0xFF7A7468),
    line: Color(0xFFE6DFD0),
    accent: Color(0xFF4A2FE0),
    accentSoft: Color(0xFFE9E5FF),
    success: Color(0xFF1F9D55),
    successSoft: Color(0xFFDFF5E8),
    error: Color(0xFFD6392B),
    errorSoft: Color(0xFFFDE6E2),
    warning: Color(0xFFB7791F),
    warningSoft: Color(0xFFFBEFD3),
    contrast: Color(0xFF1C1B19),
    onContrast: Color(0xFFE9E4D8),
  );

  static const PaperColors dark = PaperColors(
    page: Color(0xFF0D0D0F),
    background: Color(0xFF15151A),
    card: Color(0xFF1D1D24),
    ink: Color(0xFFF1EEE7),
    muted: Color(0xFF9A96A8),
    line: Color(0xFF2A2A34),
    accent: Color(0xFF9B8CFF),
    accentSoft: Color(0xFF2B2650),
    success: Color(0xFF4CD38A),
    successSoft: Color(0xFF173226),
    error: Color(0xFFFF7A6B),
    errorSoft: Color(0xFF3A1D1A),
    warning: Color(0xFFF0B955),
    warningSoft: Color(0xFF35290F),
    contrast: Color(0xFF0B0B0E),
    onContrast: Color(0xFFE9E4D8),
  );

  static PaperColors of(BuildContext context) {
    return Theme.of(context).extension<PaperColors>() ?? light;
  }

  @override
  PaperColors copyWith({
    Color? page,
    Color? background,
    Color? card,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? successSoft,
    Color? error,
    Color? errorSoft,
    Color? warning,
    Color? warningSoft,
    Color? contrast,
    Color? onContrast,
  }) {
    return PaperColors(
      page: page ?? this.page,
      background: background ?? this.background,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      error: error ?? this.error,
      errorSoft: errorSoft ?? this.errorSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      contrast: contrast ?? this.contrast,
      onContrast: onContrast ?? this.onContrast,
    );
  }

  @override
  PaperColors lerp(ThemeExtension<PaperColors>? other, double t) {
    if (other is! PaperColors) return this;
    return PaperColors(
      page: Color.lerp(page, other.page, t)!,
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      contrast: Color.lerp(contrast, other.contrast, t)!,
      onContrast: Color.lerp(onContrast, other.onContrast, t)!,
    );
  }
}

/// Convenience accessor: `context.paper.accent`.
extension PaperColorsContext on BuildContext {
  PaperColors get paper => PaperColors.of(this);
}
