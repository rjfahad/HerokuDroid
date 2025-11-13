import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokuandroid/core/constants/theme_constants.dart';
import 'package:herokuandroid/data/models/app.dart';
import 'package:herokuandroid/presentation/providers/apps_provider.dart';
import 'package:herokuandroid/presentation/screens/app_details/app_details_screen.dart';

/// Card widget to display a Heroku app
class AppCard extends StatelessWidget {
  final App app;
  final bool isGridView;

  const AppCard({super.key, required this.app, this.isGridView = false});

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppDetailsScreen(app: app)),
          );
        },
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App icon and maintenance badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ThemeConstants.primaryAccent.withOpacity(0.15),
                          ThemeConstants.secondaryAccent.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ThemeConstants.radiusM,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        app.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ThemeConstants.primaryAccent,
                        ),
                      ),
                    ),
                  ),
                  // Maintenance badge
                  if (app.maintenance == true)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ThemeConstants.statusWarning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.radiusS,
                        ),
                      ),
                      child: Icon(
                        Icons.construction,
                        size: 16,
                        color: ThemeConstants.statusWarning,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // App name
              Text(
                app.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Dyno status - real data
              _buildDynoStatus(),
              const SizedBox(height: 8),

              // Region and time
              if (app.region != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: ThemeConstants.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        app.region!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ThemeConstants.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 2),
              if (app.updatedAt != null)
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: ThemeConstants.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatTimeAgo(app.updatedAt!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: ThemeConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppDetailsScreen(app: app)),
          );
        },
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App name and maintenance badge
              Row(
                children: [
                  // App icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ThemeConstants.primaryAccent.withOpacity(0.15),
                          ThemeConstants.secondaryAccent.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ThemeConstants.radiusM,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        app.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ThemeConstants.primaryAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // App name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (app.region != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            app.region!,
                            style: const TextStyle(
                              fontSize: 13,
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
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConstants.statusWarning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.radiusS,
                        ),
                        border: Border.all(
                          color: ThemeConstants.statusWarning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.construction,
                            size: 14,
                            color: ThemeConstants.statusWarning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Maintenance',
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeConstants.statusWarning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 3-dot menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context);
                      } else if (value == 'rename') {
                        _showRenameDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: ThemeConstants.primaryAccent,
                            ),
                            SizedBox(width: 8),
                            Text('Rename App'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: ThemeConstants.statusError,
                            ),
                            SizedBox(width: 8),
                            Text('Delete App'),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Divider
              const Divider(height: 1),
              const SizedBox(height: 10),

              // App details
              Row(
                children: [
                  // Dyno status - real data
                  ..._buildDynoStatusDots(),
                  const SizedBox(width: 12),
                  if (app.region != null) ...[
                    _buildInfoChip(Icons.location_on_outlined, app.region!),
                    const SizedBox(width: 8),
                  ],
                  if (app.updatedAt != null) ...[
                    _buildInfoChip(
                      Icons.access_time_outlined,
                      _formatTimeAgo(app.updatedAt!),
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

  /// Build dyno status for grid view (compact)
  Widget _buildDynoStatus() {
    final totalDynos = app.totalDynos ?? 0;
    final runningDynos = app.runningDynos ?? 0;

    if (totalDynos == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Show up to 3 status dots
        for (int i = 0; i < (totalDynos > 3 ? 3 : totalDynos); i++)
          _buildStatusDot(
            i < runningDynos
                ? ThemeConstants.statusSuccess
                : ThemeConstants.textHint.withOpacity(0.3),
          ),
        const SizedBox(width: 4),
        Text(
          '$totalDynos ${totalDynos == 1 ? 'dyno' : 'dynos'}',
          style: const TextStyle(
            fontSize: 11,
            color: ThemeConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build dyno status dots for list view
  List<Widget> _buildDynoStatusDots() {
    final totalDynos = app.totalDynos ?? 0;
    final runningDynos = app.runningDynos ?? 0;

    if (totalDynos == 0) {
      return [];
    }

    final dots = <Widget>[];
    // Show up to 3 dots
    for (int i = 0; i < (totalDynos > 3 ? 3 : totalDynos); i++) {
      dots.add(
        _buildStatusDot(
          i < runningDynos
              ? ThemeConstants.statusSuccess
              : ThemeConstants.textHint.withOpacity(0.3),
        ),
      );
    }

    dots.addAll([
      const SizedBox(width: 8),
      Text(
        '$totalDynos ${totalDynos == 1 ? 'dyno' : 'dynos'}',
        style: const TextStyle(
          fontSize: 13,
          color: ThemeConstants.textSecondary,
        ),
      ),
    ]);

    return dots;
  }

  Widget _buildStatusDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: color == ThemeConstants.statusSuccess
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: ThemeConstants.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: ThemeConstants.textSecondary,
          ),
        ),
      ],
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete App'),
        content: Text(
          'Are you sure you want to delete "${app.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              final appsProvider = context.read<AppsProvider>();
              final success = await appsProvider.deleteApp(app.id);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${app.name} deleted successfully'),
                    backgroundColor: ThemeConstants.statusSuccess,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appsProvider.error ?? 'Failed to delete app'),
                    backgroundColor: ThemeConstants.statusError,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: ThemeConstants.statusError,
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
        title: const Text('Rename App'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'App Name',
            hintText: 'Enter new app name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App name cannot be empty'),
                    backgroundColor: ThemeConstants.statusError,
                  ),
                );
                return;
              }

              if (newName == app.name) {
                Navigator.pop(dialogContext);
                return;
              }

              Navigator.pop(dialogContext); // Close dialog
              final appsProvider = context.read<AppsProvider>();
              final success = await appsProvider.renameApp(app.id, newName);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('App renamed to "$newName" successfully'),
                    backgroundColor: ThemeConstants.statusSuccess,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appsProvider.error ?? 'Failed to rename app'),
                    backgroundColor: ThemeConstants.statusError,
                  ),
                );
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
