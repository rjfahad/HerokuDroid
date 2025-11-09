import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:herokuandroid/data/models/addon.dart';
import 'package:herokuandroid/presentation/providers/addon_provider.dart';
import 'package:herokuandroid/presentation/widgets/common/error_widget.dart'
    as custom;
import 'package:herokuandroid/presentation/widgets/common/skeleton_widgets.dart';

/// Screen for viewing add-ons
class AddonsScreen extends StatefulWidget {
  final String appId;
  final String appName;

  const AddonsScreen({required this.appId, required this.appName, super.key});

  @override
  State<AddonsScreen> createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddonProvider>().loadAddons(widget.appId);
    });
  }

  Future<void> _openDashboard(String? webUrl) async {
    if (webUrl == null || webUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dashboard URL not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final uri = Uri.parse(webUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $webUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddonProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.appName}\nAdd-ons')),
      body: _buildContent(provider),
    );
  }

  Widget _buildContent(AddonProvider provider) {
    if (provider.isLoading) {
      // Show shimmer loading effect
      return Skeletonizer(
        enabled: true,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (context, index) => const AddonSkeleton(),
        ),
      );
    }

    if (provider.error != null) {
      return custom.ErrorWidget(
        message: provider.error!,
        onRetry: () => provider.loadAddons(widget.appId),
      );
    }

    if (provider.addons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No add-ons installed',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add-ons extend your app\'s capabilities',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAddons(widget.appId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.addons.length,
        itemBuilder: (context, index) {
          final addon = provider.addons[index];
          return _AddonCard(
            addon: addon,
            onTap: () => _openDashboard(addon.webUrl),
          );
        },
      ),
    );
  }
}

/// Widget for displaying a single add-on card
class _AddonCard extends StatelessWidget {
  final Addon addon;
  final VoidCallback onTap;

  const _AddonCard({required this.addon, required this.onTap});

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'provisioned':
        return Colors.green;
      case 'provisioning':
        return Colors.orange;
      case 'deprovisioned':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String serviceName) {
    if (serviceName.contains('postgres')) {
      return Icons.storage;
    } else if (serviceName.contains('redis')) {
      return Icons.memory;
    } else if (serviceName.contains('mongo')) {
      return Icons.data_object;
    } else if (serviceName.contains('cloudinary')) {
      return Icons.image;
    } else if (serviceName.contains('sendgrid')) {
      return Icons.email;
    } else {
      return Icons.extension;
    }
  }

  String _formatServiceName(String serviceName) {
    // Convert "heroku-postgresql" to "Heroku PostgreSQL"
    return serviceName
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatPlanName(String planName) {
    // Extract plan tier from "heroku-postgresql:hobby-dev"
    final parts = planName.split(':');
    if (parts.length > 1) {
      return parts[1]
          .split('-')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }
    return planName;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and service name
              Row(
                children: [
                  Icon(
                    _getServiceIcon(addon.serviceName),
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatServiceName(addon.serviceName),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          addon.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // State badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStateColor(addon.state).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStateColor(addon.state),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      addon.state.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStateColor(addon.state),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Plan information
              Row(
                children: [
                  Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatPlanName(addon.planName),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Open dashboard link
              if (addon.webUrl != null)
                Row(
                  children: [
                    Icon(Icons.open_in_new, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Open Dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
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
}
