import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/paper_colors.dart';
import '../../../../core/theme/paper_tokens.dart';
import '../../../../data/models/app.dart';
import '../../../providers/apps_provider.dart';
import '../../../providers/dyno_provider.dart';
import '../../../providers/release_provider.dart';
import '../../../widgets/paper/paper_components.dart';
import '../../../widgets/paper/paper_snack.dart';

class OverviewTab extends StatefulWidget {
  final App app;

  const OverviewTab({super.key, required this.app});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  bool _isTogglingMaintenance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReleaseProvider>().loadReleases(widget.app.id);
    });
  }

  Future<void> _toggleMaintenanceMode(bool enabled) async {
    setState(() => _isTogglingMaintenance = true);

    final success = await context.read<AppsProvider>().toggleMaintenanceMode(
      widget.app.id,
      enabled,
    );

    if (!mounted) return;
    setState(() => _isTogglingMaintenance = false);
    PaperSnack.show(
      context,
      success
          ? (enabled
                ? 'Maintenance mode enabled'
                : 'Maintenance mode disabled')
          : 'Failed to toggle maintenance mode',
      variant: success
          ? PaperSnackVariant.success
          : PaperSnackVariant.error,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      PaperSnack.error(context, 'Could not open $url');
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    PaperSnack.show(context, '$label copied to clipboard');
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final dynoProvider = context.watch<DynoProvider>();
    final releases = context.watch<ReleaseProvider>().releases;

    final formations = dynoProvider.formations;
    final desired = formations.isNotEmpty
        ? formations.fold<int>(0, (sum, f) => sum + f.quantity)
        : (widget.app.totalDynos ?? 0);
    final running = formations.isNotEmpty
        ? desired
        : (widget.app.runningDynos ?? (widget.app.totalDynos == 0 ? 0 : desired));
    final isRunning = running > 0;

    final latest = releases.isNotEmpty ? releases.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PaperTokens.l,
        PaperTokens.s,
        PaperTokens.l,
        PaperTokens.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(
            running: running,
            desired: desired,
            isRunning: isRunning,
            subtitle: latest != null
                ? 'Last release v${latest.version}'
                      '${latest.createdAt != null ? ' · ${_timeAgo(latest.createdAt!)}' : ''}'
                : 'No releases yet',
          ),
          const SizedBox(height: PaperTokens.m),
          Row(
            children: [
              if (widget.app.webUrl != null)
                Expanded(
                  child: PaperButton(
                    label: 'Open app',
                    variant: PaperButtonVariant.outline,
                    icon: Icons.open_in_new,
                    onPressed: () => _launchUrl(widget.app.webUrl!),
                  ),
                ),
              if (widget.app.webUrl != null && widget.app.gitUrl != null)
                const SizedBox(width: PaperTokens.s),
              if (widget.app.gitUrl != null)
                Expanded(
                  child: PaperButton(
                    label: 'Git URL',
                    variant: PaperButtonVariant.outline,
                    icon: Icons.copy,
                    onPressed: () =>
                        _copyToClipboard(widget.app.gitUrl!, 'Git URL'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PaperTokens.m),
          PaperCard(
            padding: const EdgeInsets.fromLTRB(
              PaperTokens.l,
              PaperTokens.m,
              PaperTokens.l,
              PaperTokens.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: PaperTokens.xs),
                  child: PaperCaption('Details'),
                ),
                _KvRow(label: 'Region', value: widget.app.region ?? '—'),
                _KvRow(label: 'Stack', value: widget.app.stack ?? '—'),
                _KvRow(
                  label: 'Created',
                  value: _formatDate(widget.app.createdAt),
                ),
                _KvRow(
                  label: 'Updated',
                  value: _formatDate(widget.app.updatedAt),
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: PaperTokens.m),
          PaperCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maintenance mode',
                        style: PaperText.label.copyWith(
                          color: context.paper.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Show visitors a holding page',
                        style: PaperText.bodySmall.copyWith(
                          color: context.paper.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isTogglingMaintenance)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(
                    value: widget.app.maintenance ?? false,
                    onChanged: _toggleMaintenanceMode,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${DateFormat('MMM d, yyyy').format(date)} · ${_timeAgo(date)}';
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.running,
    required this.desired,
    required this.isRunning,
    required this.subtitle,
  });

  final int running;
  final int desired;
  final bool isRunning;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final statusColor = isRunning ? c.success : c.error;
    final fraction = desired > 0 ? (running / desired).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(PaperTokens.l + 2),
      decoration: BoxDecoration(
        color: c.contrast,
        borderRadius: BorderRadius.circular(PaperTokens.rHero),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    value: fraction,
                    strokeWidth: 8,
                    backgroundColor: c.onContrast.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: c.contrast,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$running',
                        style: PaperText.h2.copyWith(color: c.onContrast),
                      ),
                      Text(
                        'of $desired dynos',
                        style: TextStyle(
                          fontSize: 9,
                          color: c.onContrast.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PaperTokens.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaperTag(
                  label: isRunning ? 'running' : 'stopped',
                  variant: isRunning
                      ? PaperTagVariant.success
                      : PaperTagVariant.error,
                  dot: true,
                ),
                const SizedBox(height: PaperTokens.s),
                Text(
                  isRunning ? 'All systems go' : 'App is stopped',
                  style: PaperText.h2.copyWith(color: c.onContrast),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.onContrast.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  const _KvRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: PaperTokens.s + 1),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PaperText.body.copyWith(color: c.muted)),
          const SizedBox(width: PaperTokens.l),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: PaperText.body.copyWith(color: c.ink),
            ),
          ),
        ],
      ),
    );
  }
}
