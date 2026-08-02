import 'package:flutter/material.dart';
import 'package:herokudroid/core/constants/theme_constants.dart';

/// Loading widget with optional message
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: ThemeConstants.spacingM),
            Text(
              message!,
              style: ThemeConstants.bodyMedium.copyWith(
                color: ThemeConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
