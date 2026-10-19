import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/data/models/addon.dart';
import 'package:herokudroid/presentation/providers/addon_provider.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_snack.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_states.dart';

/// Reusable widget for displaying add-ons.
class AddonsContent extends StatefulWidget {
  final String appId;

  const AddonsContent({required this.appId, super.key});

  @override
  State<AddonsContent> createState() => _AddonsContentState();
}

class _AddonsContentState extends State<AddonsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddonProvider>().loadAddons(widget.appId);
    });
  }

  Future<void> _openDashboard(String? webUrl) async {
    if (webUrl == null || webUrl.isEmpty) {
      PaperSnack.warning(context, 'Dashboard URL not available');
      return;
    }

    final uri = Uri.parse(webUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        PaperSnack.error(context, 'Could not open $webUrl');
      }
    } catch (e) {
      if (mounted) PaperSnack.error(context, 'Failed to open: $e');
    }
  }

  Future<void> _confirmRemove(Addon addon) async {
    final confirmController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final matches = confirmController.text.trim() == addon.name;
          return AlertDialog(
            title: Text(
              'Remove ${addon.name}?',
              style: TextStyle(color: context.paper.error, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data is deleted permanently. Type the name to confirm.',
                  style: PaperText.bodySmall.copyWith(
                    color: context.paper.muted,
                  ),
                ),
                const SizedBox(height: PaperTokens.m),
                TextField(
                  controller: confirmController,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(hintText: addon.name),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
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
                onPressed: matches
                    ? () => Navigator.of(dialogContext).pop(true)
                    : null,
                child: const Text('Remove'),
              ),
            ],
          );
        },
      ),
    );

    confirmController.dispose();
    if (confirmed != true || !mounted) return;

    final provider = context.read<AddonProvider>();
    final success = await provider.removeAddon(widget.appId, addon.id);
    if (!mounted) return;
    PaperSnack.show(
      context,
      success ? 'Removed ${addon.name}' : provider.error ?? 'Failed to remove',
      variant: success ? PaperSnackVariant.success : PaperSnackVariant.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddonProvider>();

    if (provider.isLoading && provider.addons.isEmpty) {
      return const PaperLoadingState(message: 'Loading add-ons…');
    }

    if (provider.error != null && provider.addons.isEmpty) {
      return PaperErrorState(
        message: provider.error!,
        onRetry: () => provider.loadAddons(widget.appId),
      );
    }

    if (provider.addons.isEmpty) {
      return const PaperEmptyState(
        icon: Icons.extension_outlined,
        title: 'No add-ons',
        message: 'Add-ons you provision for this app will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAddons(widget.appId),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          PaperTokens.l,
          PaperTokens.s,
          PaperTokens.l,
          PaperTokens.xl,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.addons.length,
        itemBuilder: (context, index) {
          final addon = provider.addons[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: PaperTokens.s),
            child: _AddonCard(
              addon: addon,
              onOpen: () => _openDashboard(addon.webUrl),
              onRemove: () => _confirmRemove(addon),
            ),
          );
        },
      ),
    );
  }
}

class _AddonCard extends StatelessWidget {
  const _AddonCard({
    required this.addon,
    required this.onOpen,
    required this.onRemove,
  });

  final Addon addon;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  (PaperTagVariant, String) _stateTag(String state) {
    switch (state.toLowerCase()) {
      case 'provisioned':
        return (PaperTagVariant.success, 'provisioned');
      case 'provisioning':
        return (PaperTagVariant.warning, 'provisioning');
      case 'deprovisioned':
        return (PaperTagVariant.error, 'deprovisioned');
      default:
        return (PaperTagVariant.neutral, state);
    }
  }

  String _serviceTitle(String serviceName) {
    if (serviceName.toLowerCase() == 'heroku-postgresql') {
      return 'Heroku Postgres';
    }
    return serviceName
        .split('-')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String _planLabel(String planName) {
    final parts = planName.split(':');
    final plan = parts.length > 1 ? parts[1] : planName;
    return plan
        .split('-')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String _pricing(String planName) {
    final p = planName.toLowerCase();
    if (p.contains('free') || p.contains('hobby-dev')) return 'free';
    if (p.contains('mini') || p.contains('hobby-basic')) return '~\$7/mo';
    if (p.contains('essential')) return '~\$5/mo';
    if (p.contains('standard')) return '~\$50/mo';
    if (p.contains('premium')) return '~\$15/mo';
    return 'see dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final (variant, label) = _stateTag(addon.state);

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
                      _serviceTitle(addon.serviceName),
                      style: PaperText.h2.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addon.name,
                      style: PaperText.mono.copyWith(color: c.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PaperTokens.s),
              PaperTag(label: label, variant: variant),
            ],
          ),
          const SizedBox(height: PaperTokens.m),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_planLabel(addon.planName)} · ${_pricing(addon.planName)}',
                  style: PaperText.bodySmall.copyWith(color: c.muted),
                ),
              ),
              if (addon.createdAt != null)
                Text(
                  _timeAgo(addon.createdAt!),
                  style: PaperText.bodySmall.copyWith(color: c.muted),
                ),
            ],
          ),
          const SizedBox(height: PaperTokens.m),
          Row(
            children: [
              if (addon.webUrl != null && addon.webUrl!.isNotEmpty) ...[
                Expanded(
                  child: PaperButton(
                    label: 'Open dashboard',
                    variant: PaperButtonVariant.outline,
                    size: PaperButtonSize.small,
                    icon: Icons.open_in_new,
                    onPressed: onOpen,
                  ),
                ),
                const SizedBox(width: PaperTokens.s),
              ],
              Expanded(
                child: PaperButton(
                  label: 'Remove',
                  variant: PaperButtonVariant.destructive,
                  size: PaperButtonSize.small,
                  icon: Icons.delete_outline,
                  onPressed: onRemove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }
}
