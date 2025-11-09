import 'package:flutter/material.dart';
import 'package:herokuandroid/core/constants/theme_constants.dart';
import 'package:herokuandroid/data/models/app.dart';
import 'package:intl/intl.dart';

/// Card widget to display a Heroku app
class AppCard extends StatelessWidget {
  final App app;

  const AppCard({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to app details screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${app.name}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App name and maintenance badge
              Row(
                children: [
                  // App icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ThemeConstants.herokuPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        ThemeConstants.radiusM,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        app.name[0].toUpperCase(),
                        style: ThemeConstants.headingMedium.copyWith(
                          color: ThemeConstants.herokuPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ThemeConstants.spacingM),

                  // App name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: ThemeConstants.headingSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (app.region != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            app.region!,
                            style: ThemeConstants.bodySmall.copyWith(
                              color: ThemeConstants.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Maintenance badge
                  if (app.maintenance == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.spacingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConstants.statusWarning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.radiusS,
                        ),
                        border: Border.all(color: ThemeConstants.statusWarning),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.construction,
                            size: ThemeConstants.iconSizeS,
                            color: ThemeConstants.statusWarning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Maintenance',
                            style: ThemeConstants.bodySmall.copyWith(
                              color: ThemeConstants.statusWarning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: ThemeConstants.spacingM),

              // Divider
              const Divider(height: 1),
              const SizedBox(height: ThemeConstants.spacingM),

              // App details
              Row(
                children: [
                  if (app.stack != null) ...[
                    _buildInfoChip(Icons.layers, app.stack!),
                    const SizedBox(width: ThemeConstants.spacingS),
                  ],
                  if (app.createdAt != null) ...[
                    _buildInfoChip(
                      Icons.calendar_today,
                      _formatDate(app.createdAt!),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: ThemeConstants.iconSizeS,
          color: ThemeConstants.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: ThemeConstants.bodySmall.copyWith(
            color: ThemeConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
