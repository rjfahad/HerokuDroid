import 'package:flutter/material.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';

/// Centered loading indicator with an optional caption.
class PaperLoadingState extends StatelessWidget {
  const PaperLoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          if (message != null) ...[
            const SizedBox(height: PaperTokens.m),
            Text(
              message!,
              style: PaperText.bodySmall.copyWith(color: c.muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Friendly empty state with an icon, title, message and optional action.
class PaperEmptyState extends StatelessWidget {
  const PaperEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PaperTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.card,
                shape: BoxShape.circle,
                border: Border.all(color: c.line),
              ),
              child: Icon(icon, size: 28, color: c.muted),
            ),
            const SizedBox(height: PaperTokens.l),
            Text(
              title,
              style: PaperText.h3.copyWith(color: c.ink),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: PaperTokens.s),
              Text(
                message!,
                style: PaperText.bodySmall.copyWith(color: c.muted),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: PaperTokens.l),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry affordance.
class PaperErrorState extends StatelessWidget {
  const PaperErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PaperTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.errorSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 28, color: c.error),
            ),
            const SizedBox(height: PaperTokens.l),
            Text(
              'Something went wrong',
              style: PaperText.h3.copyWith(color: c.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PaperTokens.s),
            Text(
              message,
              style: PaperText.bodySmall.copyWith(color: c.muted),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: PaperTokens.l),
              PaperButton(
                label: 'Try again',
                variant: PaperButtonVariant.outline,
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
