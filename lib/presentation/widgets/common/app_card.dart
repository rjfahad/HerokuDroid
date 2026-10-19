import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/data/models/app.dart';
import 'package:herokudroid/presentation/providers/apps_provider.dart';
import 'package:herokudroid/presentation/screens/app_details/app_details_screen.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_snack.dart';
import 'package:herokudroid/presentation/widgets/paper/swipe_reveal.dart';

/// App card — Design B (Paper). List view supports swipe-to-reveal actions;
/// grid view is a compact tile.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.app, this.isGridView = false});

  final App app;
  final bool isGridView;

  bool get _statusKnown => app.totalDynos != null;
  bool get _isRunning => (app.runningDynos ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    if (isGridView) return _buildGridCard(context);
    return SwipeReveal(
      actions: [
        RevealAction(
          icon: Icons.edit_outlined,
          label: 'Rename',
          color: context.paper.accent,
          background: context.paper.accentSoft,
          onTap: () => _showRenameDialog(context),
        ),
        RevealAction(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: context.paper.error,
          background: context.paper.errorSoft,
          onTap: () => _showDeleteConfirmation(context),
        ),
      ],
      child: _buildListCard(context),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final c = context.paper;
    final tag = _buildStatusTag();
    return PaperCard(
      onTap: () => _openDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  app.name,
                  style: PaperText.h3.copyWith(color: c.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tag != null) ...[
                const SizedBox(width: 6),
                tag,
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _metaLine(),
            style: PaperText.bodySmall.copyWith(color: c.muted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final c = context.paper;
    final tag = _buildStatusTag();
    return PaperCard(
      onTap: () => _openDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  app.name,
                  style: PaperText.h3.copyWith(fontSize: 17, color: c.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tag != null) ...[
                const SizedBox(width: 8),
                tag,
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _metaLine(),
            style: PaperText.bodySmall.copyWith(color: c.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          _Spark(seed: app.id),
        ],
      ),
    );
  }

  Widget? _buildStatusTag() {
    if (!_statusKnown) return null;
    return _isRunning
        ? const PaperTag(
            label: 'running',
            variant: PaperTagVariant.success,
            dot: true,
          )
        : const PaperTag(
            label: 'stopped',
            variant: PaperTagVariant.error,
            dot: true,
          );
  }

  String _metaLine() {
    final parts = <String>[
      if (app.region != null && app.region!.isNotEmpty) app.region!,
      if (app.stack != null && app.stack!.isNotEmpty) app.stack!,
      if (app.updatedAt != null) _formatTimeAgo(app.updatedAt!),
    ];
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AppDetailsScreen(app: app)),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
    return '${(difference.inDays / 365).floor()}y ago';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete app'),
        content: Text(
          'Are you sure you want to delete "${app.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final appsProvider = context.read<AppsProvider>();
              final success = await appsProvider.deleteApp(app.id);

              if (!context.mounted) return;
              PaperSnack.show(
                context,
                success
                    ? '${app.name} deleted'
                    : appsProvider.error ?? 'Failed to delete app',
                variant: success
                    ? PaperSnackVariant.success
                    : PaperSnackVariant.error,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: context.paper.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final nameController = TextEditingController(text: app.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename app'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New app name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty || newName == app.name) {
                Navigator.pop(dialogContext);
                return;
              }
              Navigator.pop(dialogContext);
              final appsProvider = context.read<AppsProvider>();
              final success = await appsProvider.renameApp(app.id, newName);

              if (!context.mounted) return;
              PaperSnack.show(
                context,
                success
                    ? 'App renamed to "$newName"'
                    : appsProvider.error ?? 'Failed to rename app',
                variant: success
                    ? PaperSnackVariant.success
                    : PaperSnackVariant.error,
              );
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}

/// Decorative activity sparkline — deterministic per app so it stays stable
/// between rebuilds.
class _Spark extends StatelessWidget {
  const _Spark({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final hash = seed.hashCode;
    const barCount = 7;
    return SizedBox(
      height: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < barCount; i++) ...[
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.3 + (((hash >> (i * 3)) & 0x7) / 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.accent.withValues(
                        alpha: i == barCount - 1 ? 1.0 : 0.35,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            if (i != barCount - 1) const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}
