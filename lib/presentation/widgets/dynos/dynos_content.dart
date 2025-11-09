import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokuandroid/data/models/formation.dart';
import 'package:herokuandroid/presentation/providers/dyno_provider.dart';
import 'package:herokuandroid/presentation/widgets/common/error_widget.dart'
    as custom;
import 'package:herokuandroid/presentation/widgets/common/loading_widget.dart';

/// Reusable widget for displaying and managing dynos
class DynosContent extends StatefulWidget {
  final String appId;

  const DynosContent({required this.appId, super.key});

  @override
  State<DynosContent> createState() => _DynosContentState();
}

class _DynosContentState extends State<DynosContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DynoProvider>().loadFormation(widget.appId);
    });
  }

  Future<void> _showScaleDialog(Formation formation) async {
    final quantityController = TextEditingController(
      text: formation.quantity.toString(),
    );
    String selectedSize = formation.size;

    final availableSizes = [
      'basic',
      'hobby',
      'standard-1x',
      'standard-2x',
      'performance-m',
      'performance-l',
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Scale ${formation.type}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  helperText: 'Number of dynos (0 to disable)',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSize,
                decoration: const InputDecoration(labelText: 'Dyno Size'),
                items: availableSizes
                    .map(
                      (size) =>
                          DropdownMenuItem(value: size, child: Text(size)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedSize = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                Navigator.of(
                  context,
                ).pop({'quantity': quantity, 'size': selectedSize});
              },
              child: const Text('Scale'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      final success = await context.read<DynoProvider>().scaleFormation(
        appId: widget.appId,
        formationId: formation.id,
        quantity: result['quantity'] as int,
        size: result['size'] as String,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Scaled ${formation.type} successfully'
                  : 'Failed to scale ${formation.type}',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restartDynos(String type) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restart $type dynos?'),
        content: const Text('This will restart all dynos of this type.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Restart'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<DynoProvider>().restartDynosByType(
        widget.appId,
        type,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Restarted $type dynos'
                  : 'Failed to restart $type dynos',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DynoProvider>();

    if (provider.isLoading) {
      return const LoadingWidget(message: 'Loading dyno formation...');
    }

    if (provider.error != null) {
      return custom.ErrorWidget(
        message: provider.error!,
        onRetry: () => provider.loadFormation(widget.appId),
      );
    }

    if (provider.formations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dns_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No dyno formations',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'No process types configured for this app',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshFormation(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.formations.length + 1, // +1 for restart all button
        itemBuilder: (context, index) {
          if (index == provider.formations.length) {
            // Restart All button at the bottom
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: OutlinedButton.icon(
                onPressed: _restartAllDynos,
                icon: const Icon(Icons.refresh),
                label: const Text('Restart All Dynos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            );
          }

          final formation = provider.formations[index];
          return FormationCard(
            formation: formation,
            appId: widget.appId,
            onScale: () => _showScaleDialog(formation),
            onRestart: () => _restartDynos(formation.type),
          );
        },
      ),
    );
  }

  Future<void> _restartAllDynos() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart All Dynos?'),
        content: const Text(
          'This will restart all dynos for all process types. '
          'This may cause brief downtime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Restart All'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Restart all formations
      bool allSuccess = true;
      for (final formation in context.read<DynoProvider>().formations) {
        if (formation.isScaled) {
          final success = await context.read<DynoProvider>().restartDynosByType(
            widget.appId,
            formation.type,
          );
          if (!success) allSuccess = false;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              allSuccess
                  ? 'Restarted all dynos'
                  : 'Some dynos failed to restart',
            ),
            backgroundColor: allSuccess ? Colors.green : Colors.orange,
          ),
        );
      }
    }
  }
}

/// Widget for displaying a single formation card
class FormationCard extends StatelessWidget {
  final Formation formation;
  final String appId;
  final VoidCallback onScale;
  final VoidCallback onRestart;

  const FormationCard({
    required this.formation,
    required this.appId,
    required this.onScale,
    required this.onRestart,
    super.key,
  });

  Color _getStatusColor() {
    return formation.isScaled ? Colors.green : Colors.grey;
  }

  IconData _getTypeIcon() {
    switch (formation.type.toLowerCase()) {
      case 'web':
        return Icons.public;
      case 'worker':
        return Icons.work;
      default:
        return Icons.dns;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and type
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getTypeIcon(), color: _getStatusColor()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formation.type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formation.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getStatusColor()),
                  ),
                  child: Text(
                    formation.isScaled ? 'Running' : 'Stopped',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            if (formation.command != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.code, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formation.command!,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Dyno instances
            if (formation.isScaled) ...[
              ...List.generate(formation.quantity, (index) {
                final dynoNumber = index + 1;
                final dynoName = '${formation.type}.$dynoNumber';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dynoName,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text(
                          'up',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '2h', // Placeholder for uptime
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Stop individual dyno
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Stop',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ] else ...[
              Text(
                '(no dynos running)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onScale,
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Scale'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: formation.isScaled ? onRestart : null,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Restart'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
