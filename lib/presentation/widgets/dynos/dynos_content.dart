import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/data/models/formation.dart';
import 'package:herokudroid/presentation/providers/dyno_provider.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_snack.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_states.dart';

/// Reusable widget for displaying and managing dynos.
class DynosContent extends StatefulWidget {
  final String appId;

  const DynosContent({required this.appId, super.key});

  @override
  State<DynosContent> createState() => _DynosContentState();
}

class _DynosContentState extends State<DynosContent> {
  static const _baseSizes = [
    'eco',
    'basic',
    'standard-1x',
    'standard-2x',
    'performance-m',
    'performance-l',
    'performance-l-ram',
    'performance-xl',
    'performance-2xl',
  ];

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

    final availableSizes = <String>[
      if (!_baseSizes.contains(formation.size)) formation.size,
      ..._baseSizes,
    ];
    var selectedSize = formation.size;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Scale ${formation.type}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PaperTextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                hintText: 'Quantity (0 to stop)',
              ),
              const SizedBox(height: PaperTokens.l),
              DropdownButtonFormField<String>(
                initialValue: selectedSize,
                decoration: const InputDecoration(labelText: 'Dyno size'),
                items: availableSizes
                    .map(
                      (size) =>
                          DropdownMenuItem(value: size, child: Text(size)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedSize = value);
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
            FilledButton(
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

    if (result == null || !mounted) return;

    final success = await context.read<DynoProvider>().scaleFormation(
      appId: widget.appId,
      formationId: formation.id,
      quantity: result['quantity'] as int,
      size: result['size'] as String,
    );

    if (!mounted) return;
    PaperSnack.show(
      context,
      success
          ? 'Scaled ${formation.type} successfully'
          : 'Failed to scale ${formation.type}',
      variant: success ? PaperSnackVariant.success : PaperSnackVariant.error,
    );
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
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<DynoProvider>().restartDynosByType(
      widget.appId,
      type,
    );

    if (!mounted) return;
    PaperSnack.show(
      context,
      success ? 'Restarted $type dynos' : 'Failed to restart $type dynos',
      variant: success ? PaperSnackVariant.success : PaperSnackVariant.error,
    );
  }

  Future<void> _restartAllDynos() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart all dynos?'),
        content: const Text(
          'This will restart every process type. This may cause brief downtime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restart all'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<DynoProvider>();
    var allSuccess = true;

    for (final formation in provider.formations.where((f) => f.isScaled)) {
      if (!mounted) return;
      final success = await provider.restartDynosByType(
        widget.appId,
        formation.type,
      );
      if (!success) allSuccess = false;
    }

    if (!mounted) return;
    PaperSnack.show(
      context,
      allSuccess ? 'Restarted all dynos' : 'Some dynos failed to restart',
      variant: allSuccess
          ? PaperSnackVariant.success
          : PaperSnackVariant.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DynoProvider>();

    if (provider.isLoading && provider.formations.isEmpty) {
      return const PaperLoadingState(message: 'Loading dyno formation…');
    }

    if (provider.error != null && provider.formations.isEmpty) {
      return PaperErrorState(
        message: provider.error!,
        onRetry: () => provider.loadFormation(widget.appId),
      );
    }

    if (provider.formations.isEmpty) {
      return const PaperEmptyState(
        icon: Icons.dns_outlined,
        title: 'No dyno formations',
        message: 'This app has no process types configured.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshFormation(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          PaperTokens.l,
          PaperTokens.s,
          PaperTokens.l,
          PaperTokens.xl,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          for (final formation in provider.formations) ...[
            _FormationCard(
              formation: formation,
              onScale: () => _showScaleDialog(formation),
              onRestart: () => _restartDynos(formation.type),
            ),
            const SizedBox(height: PaperTokens.m),
          ],
          const SizedBox(height: PaperTokens.xs),
          PaperButton(
            label: 'Restart all dynos',
            variant: PaperButtonVariant.destructive,
            icon: Icons.restart_alt,
            expand: true,
            onPressed: _restartAllDynos,
          ),
        ],
      ),
    );
  }
}

class _FormationCard extends StatelessWidget {
  const _FormationCard({
    required this.formation,
    required this.onScale,
    required this.onRestart,
  });

  final Formation formation;
  final VoidCallback onScale;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formation.type,
                      style: PaperText.h2.copyWith(color: c.ink),
                    ),
                    if (formation.command != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        formation.command!,
                        style: PaperText.mono.copyWith(color: c.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: PaperTokens.s),
              PaperTag(
                label: formation.isScaled
                    ? '${formation.quantity} running'
                    : 'stopped',
                variant: formation.isScaled
                    ? PaperTagVariant.success
                    : PaperTagVariant.error,
              ),
            ],
          ),
          if (formation.isScaled) ...[
            const SizedBox(height: PaperTokens.m),
            for (var i = 0; i < formation.quantity; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : PaperTokens.s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PaperTokens.m,
                    vertical: PaperTokens.s + 1,
                  ),
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(PaperTokens.rInput),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: c.success),
                      const SizedBox(width: PaperTokens.s),
                      Text(
                        '${formation.type}.${i + 1}',
                        style: PaperText.label.copyWith(
                          fontFamily: 'monospace',
                          color: c.ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formation.size,
                        style: PaperText.bodySmall.copyWith(color: c.muted),
                      ),
                    ],
                  ),
                ),
              ),
          ] else ...[
            const SizedBox(height: PaperTokens.m),
            Text(
              'No dynos running',
              style: PaperText.bodySmall.copyWith(
                color: c.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: PaperTokens.m),
          Row(
            children: [
              Expanded(
                child: PaperButton(
                  label: 'Scale · ${formation.size}',
                  variant: PaperButtonVariant.outline,
                  size: PaperButtonSize.small,
                  icon: Icons.tune,
                  onPressed: onScale,
                ),
              ),
              const SizedBox(width: PaperTokens.s),
              Expanded(
                child: PaperButton(
                  label: 'Restart',
                  variant: PaperButtonVariant.outline,
                  size: PaperButtonSize.small,
                  icon: Icons.refresh,
                  onPressed: formation.isScaled ? onRestart : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
