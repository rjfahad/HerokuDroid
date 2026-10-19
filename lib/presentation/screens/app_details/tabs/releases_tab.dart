import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/paper_colors.dart';
import '../../../../core/theme/paper_tokens.dart';
import '../../../../data/models/app.dart';
import '../../../../data/models/release.dart';
import '../../../providers/release_provider.dart';
import '../../../widgets/paper/paper_components.dart';
import '../../../widgets/paper/paper_snack.dart';
import '../../../widgets/paper/paper_states.dart';

class ReleasesTab extends StatefulWidget {
  final App app;

  const ReleasesTab({super.key, required this.app});

  @override
  State<ReleasesTab> createState() => _ReleasesTabState();
}

class _ReleasesTabState extends State<ReleasesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReleaseProvider>().loadReleases(widget.app.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReleaseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasReleases) {
          return const PaperLoadingState(message: 'Loading releases…');
        }

        if (provider.error != null && !provider.hasReleases) {
          return PaperErrorState(
            message: provider.error!,
            onRetry: () => provider.loadReleases(widget.app.id),
          );
        }

        if (!provider.hasReleases) {
          return const PaperEmptyState(
            icon: Icons.history,
            title: 'No releases found',
            message: 'Deploy history will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshReleases(widget.app.id),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              PaperTokens.l,
              PaperTokens.s,
              PaperTokens.l,
              PaperTokens.xl,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.releases.length,
            itemBuilder: (context, index) {
              final release = provider.releases[index];
              return _TimelineItem(
                release: release,
                isFirst: index == 0,
                isLast: index == provider.releases.length - 1,
                canRollback: index != 0 && release.status == 'succeeded',
                onRollback: () => _confirmRollback(release),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmRollback(Release release) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Roll back?'),
        content: Text(
          'This creates a new release from v${release.version}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.paper.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Roll back'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<ReleaseProvider>();
    final version = release.version;
    final success = await provider.rollbackRelease(widget.app.id, release.id);

    if (!mounted) return;
    PaperSnack.show(
      context,
      success
          ? 'Rolled back to v$version'
          : provider.error ?? 'Failed to roll back',
      variant: success ? PaperSnackVariant.success : PaperSnackVariant.error,
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.release,
    required this.isFirst,
    required this.isLast,
    required this.canRollback,
    required this.onRollback,
  });

  final Release release;
  final bool isFirst;
  final bool isLast;
  final bool canRollback;
  final VoidCallback onRollback;

  (PaperTagVariant, Color, String) _status(PaperColors c) {
    switch (release.status?.toLowerCase()) {
      case 'succeeded':
        return (PaperTagVariant.success, c.success, 'succeeded');
      case 'failed':
        return (PaperTagVariant.error, c.error, 'failed');
      case 'pending':
        return (PaperTagVariant.warning, c.warning, 'pending');
      default:
        return (
          PaperTagVariant.neutral,
          c.muted,
          release.status ?? 'unknown',
        );
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final (variant, dotColor, label) = _status(c);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.background, width: 3),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: c.line),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : PaperTokens.m),
              child: PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'v${release.version}',
                          style: PaperText.h2.copyWith(color: c.ink),
                        ),
                        const SizedBox(width: PaperTokens.s),
                        PaperTag(label: label, variant: variant),
                        const Spacer(),
                        if (release.createdAt != null)
                          Text(
                            _timeAgo(release.createdAt!),
                            style: PaperText.bodySmall.copyWith(color: c.muted),
                          ),
                      ],
                    ),
                    if (release.description != null &&
                        release.description!.isNotEmpty) ...[
                      const SizedBox(height: PaperTokens.s),
                      Text(
                        release.description!,
                        style: PaperText.body.copyWith(color: c.ink),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (release.userEmail != null) ...[
                      const SizedBox(height: PaperTokens.xs),
                      Text(
                        release.userEmail!,
                        style: PaperText.bodySmall.copyWith(color: c.muted),
                      ),
                    ],
                    if (isFirst && release.status == 'succeeded') ...[
                      const SizedBox(height: PaperTokens.s),
                      const PaperTag(
                        label: 'current',
                        variant: PaperTagVariant.accent,
                      ),
                    ],
                    if (canRollback) ...[
                      const SizedBox(height: PaperTokens.m),
                      PaperButton(
                        label: 'Roll back',
                        variant: PaperButtonVariant.destructive,
                        size: PaperButtonSize.small,
                        icon: Icons.history,
                        onPressed: onRollback,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
