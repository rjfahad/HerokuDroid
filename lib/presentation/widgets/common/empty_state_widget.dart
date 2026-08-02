import 'package:flutter/material.dart';
import 'package:herokudroid/core/constants/theme_constants.dart';

/// Empty state widget with icon and message
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? description;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ThemeConstants.iconSizeXl * 1.5,
              color: ThemeConstants.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            Text(
              message,
              style: ThemeConstants.headingMedium.copyWith(
                color: ThemeConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: ThemeConstants.spacingS),
              Text(
                description!,
                style: ThemeConstants.bodyMedium.copyWith(
                  color: ThemeConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
