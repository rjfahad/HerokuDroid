import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:herokudroid/core/constants/update_constants.dart';
import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/data/models/app_update.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_snack.dart';

/// Shows the "update available" dialog.
///
/// Returns true when the user chose to update (and the download page was
/// opened), false when they dismissed it.
Future<bool> showUpdateDialog(BuildContext context, AppUpdate update) async {
  final c = context.paper;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Update available'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HerokuDroid ${update.version} is ready to install.',
            style: PaperText.body.copyWith(color: c.ink),
          ),
          if (update.notes != null) ...[
            const SizedBox(height: PaperTokens.s),
            Text(
              update.notes!,
              style: PaperText.bodySmall.copyWith(color: c.muted),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Update'),
        ),
      ],
    ),
  );

  if (result == true && context.mounted) {
    await openUpdateUrl(
      context,
      update.downloadUrl ?? UpdateConstants.releasesPage,
    );
  }
  return result ?? false;
}

/// Open the update URL in the platform browser.
Future<void> openUpdateUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (context.mounted) PaperSnack.error(context, 'Could not open $url');
  } catch (e) {
    if (context.mounted) PaperSnack.error(context, 'Failed to open: $e');
  }
}
