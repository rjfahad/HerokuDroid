import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokuandroid/core/constants/theme_constants.dart';
import 'package:herokuandroid/data/models/app.dart';
import 'package:herokuandroid/data/models/release.dart';
import 'package:herokuandroid/presentation/providers/release_provider.dart';

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
      builder: (context, releaseProvider, _) {
        if (releaseProvider.isLoading && !releaseProvider.hasReleases) {
          return const Center(child: CircularProgressIndicator());
        }

        if (releaseProvider.error != null && !releaseProvider.hasReleases) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: ThemeConstants.statusError,
                ),
                const SizedBox(height: 16),
                Text(
                  releaseProvider.error!,
                  style: ThemeConstants.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    releaseProvider.loadReleases(widget.app.id);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!releaseProvider.hasReleases) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: ThemeConstants.textSecondary,
                ),
                const SizedBox(height: 16),
                Text('No releases found', style: ThemeConstants.headingMedium),
                const SizedBox(height: 8),
                Text(
                  'Deploy history will appear here',
                  style: ThemeConstants.bodyMedium.copyWith(
                    color: ThemeConstants.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => releaseProvider.refreshReleases(widget.app.id),
          child: ListView.separated(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            itemCount: releaseProvider.releases.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: ThemeConstants.spacingS),
            itemBuilder: (context, index) {
              final release = releaseProvider.releases[index];
              return _buildReleaseCard(release);
            },
          ),
        );
      },
    );
  }

  Widget _buildReleaseCard(Release release) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Version badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConstants.primaryAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
                    border: Border.all(
                      color: ThemeConstants.primaryAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'v${release.version}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeConstants.primaryAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Status badge
                if (release.status != null) _buildStatusBadge(release.status!),
                const Spacer(),
                // Timestamp
                if (release.createdAt != null)
                  Text(
                    _formatTimeAgo(release.createdAt!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeConstants.textSecondary,
                    ),
                  ),
              ],
            ),
            if (release.description != null) ...[
              const SizedBox(height: 12),
              Text(
                release.description!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (release.userEmail != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: ThemeConstants.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    release.userEmail!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ThemeConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            if (release.createdAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: ThemeConstants.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatFullDate(release.createdAt!),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ThemeConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'succeeded':
        color = ThemeConstants.statusSuccess;
        icon = Icons.check_circle_outline;
        break;
      case 'failed':
        color = ThemeConstants.statusError;
        icon = Icons.error_outline;
        break;
      case 'pending':
        color = ThemeConstants.statusWarning;
        icon = Icons.pending_outlined;
        break;
      default:
        color = ThemeConstants.textSecondary;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
