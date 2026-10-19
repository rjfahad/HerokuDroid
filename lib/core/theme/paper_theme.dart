import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'paper_colors.dart';
import 'paper_tokens.dart';

/// Builds the Design B (Paper) [ThemeData] for both brightnesses.
class PaperTheme {
  PaperTheme._();

  static ThemeData get light => _build(PaperColors.light, Brightness.light);
  static ThemeData get dark => _build(PaperColors.dark, Brightness.dark);

  static ThemeData _build(PaperColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: brightness,
      primary: c.accent,
      onPrimary: Colors.white,
      secondary: c.accent,
      onSecondary: Colors.white,
      surface: c.background,
      onSurface: c.ink,
      error: c.error,
      onError: Colors.white,
      outline: c.line,
    );

    final serif = PaperText.h1;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      cardColor: c.card,
      dividerColor: c.line,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[c],
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, c),
      primaryTextTheme: _textTheme(base.primaryTextTheme, c),
      iconTheme: IconThemeData(color: c.ink, size: 20),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: serif.copyWith(color: c.ink, fontSize: 22),
        iconTheme: IconThemeData(color: c.ink, size: 22),
        actionsIconTheme: IconThemeData(color: c.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PaperTokens.rCard),
          side: BorderSide(color: c.line),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: c.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PaperTokens.m + 2,
          vertical: PaperTokens.m + 2,
        ),
        hintStyle: PaperText.body.copyWith(color: c.muted),
        labelStyle: PaperText.body.copyWith(color: c.muted),
        floatingLabelStyle: PaperText.bodySmall.copyWith(color: c.accent),
        errorStyle: PaperText.bodySmall.copyWith(color: c.error),
        border: _inputBorder(c.line),
        enabledBorder: _inputBorder(c.line),
        disabledBorder: _inputBorder(c.line),
        focusedBorder: _inputBorder(c.accent, width: 1.6),
        errorBorder: _inputBorder(c.error),
        focusedErrorBorder: _inputBorder(c.error, width: 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(
          background: c.ink,
          foreground: c.background,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(background: c.accent, foreground: Colors.white),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.ink,
          textStyle: PaperText.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PaperTokens.rPill),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: PaperTokens.l,
            vertical: PaperTokens.m,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          textStyle: PaperText.label,
          side: BorderSide(color: c.line),
          padding: const EdgeInsets.symmetric(
            horizontal: PaperTokens.l,
            vertical: PaperTokens.m,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PaperTokens.rPill),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.card,
        selectedColor: c.accentSoft,
        labelStyle: PaperText.bodySmall.copyWith(color: c.muted),
        secondaryLabelStyle: PaperText.bodySmall.copyWith(color: c.accent),
        side: BorderSide(color: c.line),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: PaperTokens.m,
          vertical: PaperTokens.xs,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PaperTokens.rSheet),
          side: BorderSide(color: c.line),
        ),
        titleTextStyle: PaperText.h2.copyWith(color: c.ink),
        contentTextStyle: PaperText.body.copyWith(color: c.muted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PaperTokens.rHero),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.contrast,
        contentTextStyle: PaperText.bodySmall.copyWith(
          color: c.onContrast,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: c.onContrast,
        insetPadding: const EdgeInsets.all(PaperTokens.l),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PaperTokens.rInput),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : c.card,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.accent : c.line,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.line,
        circularTrackColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.ink,
        textColor: c.ink,
        subtitleTextStyle: PaperText.bodySmall.copyWith(color: c.muted),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PaperTokens.rInput),
          side: BorderSide(color: c.line),
        ),
        textStyle: PaperText.body.copyWith(color: c.ink),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.ink,
          borderRadius: BorderRadius.circular(PaperTokens.s),
        ),
        textStyle: PaperText.bodySmall.copyWith(color: c.background),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(PaperTokens.rInput),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ButtonStyle _buttonStyle({
    required Color background,
    required Color foreground,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: background.withValues(alpha: 0.4),
      disabledForegroundColor: foreground.withValues(alpha: 0.7),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: PaperTokens.l + 2,
        vertical: PaperTokens.m + 1,
      ),
      textStyle: PaperText.label,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PaperTokens.rPill),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, PaperColors c) {
    TextTheme serifify(TextTheme t) => t.copyWith(
      displayLarge: PaperText.hero.copyWith(color: c.ink),
      displayMedium: PaperText.h1.copyWith(color: c.ink),
      displaySmall: PaperText.h1.copyWith(color: c.ink),
      headlineLarge: PaperText.h1.copyWith(color: c.ink),
      headlineMedium: PaperText.h2.copyWith(color: c.ink),
      headlineSmall: PaperText.h2.copyWith(color: c.ink),
      titleLarge: PaperText.h2.copyWith(color: c.ink),
      titleMedium: PaperText.h3.copyWith(color: c.ink),
      titleSmall: PaperText.label.copyWith(color: c.ink),
      bodyLarge: PaperText.body.copyWith(color: c.ink),
      bodyMedium: PaperText.body.copyWith(color: c.ink),
      bodySmall: PaperText.bodySmall.copyWith(color: c.muted),
      labelLarge: PaperText.label.copyWith(color: c.ink),
      labelMedium: PaperText.caption.copyWith(color: c.muted),
      labelSmall: PaperText.caption.copyWith(color: c.muted),
    );
    return serifify(base.apply(fontFamily: null));
  }
}
