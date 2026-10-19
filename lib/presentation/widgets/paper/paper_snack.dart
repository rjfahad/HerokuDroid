import 'package:flutter/material.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';

enum PaperSnackVariant { neutral, success, error, warning }

/// Design B toast. Renders as an always-dark floating pill (matching the
/// mockup's `.toast`) with an optional status icon.
class PaperSnack {
  PaperSnack._();

  static void show(
    BuildContext context,
    String message, {
    PaperSnackVariant variant = PaperSnackVariant.neutral,
    Duration duration = const Duration(seconds: 2),
  }) {
    final c = PaperColors.of(context);
    final (IconData? icon, Color iconColor) = switch (variant) {
      PaperSnackVariant.neutral => (null, c.onContrast),
      PaperSnackVariant.success => (Icons.check_circle_outline, c.success),
      PaperSnackVariant.error => (Icons.error_outline, c.error),
      PaperSnackVariant.warning => (
        Icons.warning_amber_rounded,
        c.warning,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: PaperTokens.m),
              ],
              Expanded(
                child: Text(
                  message,
                  style: PaperText.bodySmall.copyWith(
                    color: c.onContrast,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, variant: PaperSnackVariant.success);

  static void error(BuildContext context, String message) =>
      show(context, message, variant: PaperSnackVariant.error);

  static void warning(BuildContext context, String message) =>
      show(context, message, variant: PaperSnackVariant.warning);
}
