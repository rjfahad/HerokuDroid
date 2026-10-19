import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/presentation/providers/config_provider.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_snack.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_states.dart';

/// Reusable widget for displaying and managing config vars.
class ConfigVarsContent extends StatefulWidget {
  final String appId;
  final bool showFab;

  const ConfigVarsContent({
    required this.appId,
    this.showFab = true,
    super.key,
  });

  @override
  State<ConfigVarsContent> createState() => _ConfigVarsContentState();
}

class _ConfigVarsContentState extends State<ConfigVarsContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigProvider>().loadConfigVars(widget.appId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> _filtered(Map<String, String> configVars) {
    if (_searchQuery.isEmpty) return configVars.entries.toList();
    final q = _searchQuery.toLowerCase();
    return configVars.entries
        .where(
          (e) =>
              e.key.toLowerCase().contains(q) ||
              e.value.toLowerCase().contains(q),
        )
        .toList();
  }

  void _showAddEditDialog({String? existingKey, String? existingValue}) {
    final keyController = TextEditingController(text: existingKey);
    final valueController = TextEditingController(text: existingValue);
    final formKey = GlobalKey<FormState>();
    final isEditing = existingKey != null;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'Edit config var' : 'New variable'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: keyController,
                enabled: !isEditing,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Key',
                  hintText: 'DATABASE_URL',
                  helperText: 'Uppercase with underscores',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9_]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a key';
                  }
                  if (value.contains(' ')) {
                    return 'Key cannot contain spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: PaperTokens.l),
              TextFormField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  hintText: 'postgres://…',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final navigator = Navigator.of(dialogContext);
              final keyText = keyController.text.trim();
              navigator.pop();

              final success = await context
                  .read<ConfigProvider>()
                  .setConfigVar(
                    widget.appId,
                    keyText,
                    valueController.text.trim(),
                  );
              if (!mounted) return;
              PaperSnack.show(
                context,
                success
                    ? '${isEditing ? 'Updated' : 'Added'} $keyText'
                    : 'Failed to ${isEditing ? 'update' : 'add'} config var',
                variant: success
                    ? PaperSnackVariant.success
                    : PaperSnackVariant.error,
              );
            },
            child: Text(isEditing ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(String key) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete config var'),
        content: Text('Are you sure you want to delete "$key"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.paper.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return false;

    final success = await context.read<ConfigProvider>().deleteConfigVar(
      widget.appId,
      key,
    );
    if (!mounted) return true;
    PaperSnack.show(
      context,
      success ? 'Deleted $key' : 'Failed to delete config var',
      variant: success ? PaperSnackVariant.success : PaperSnackVariant.error,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.paper.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PaperTokens.l,
              PaperTokens.s,
              PaperTokens.l,
              PaperTokens.s,
            ),
            child: PaperTextField(
              controller: _searchController,
              hintText: 'Filter variables',
              onChanged: (value) => setState(() => _searchQuery = value),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffix: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
            ),
          ),
          Expanded(
            child: Consumer<ConfigProvider>(
              builder: (context, provider, _) => _buildContent(provider),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.showFab
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              tooltip: 'Add config var',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildContent(ConfigProvider provider) {
    if (provider.isLoading && provider.configVars.isEmpty) {
      return const PaperLoadingState(message: 'Loading config vars…');
    }

    if (provider.error != null && provider.configVars.isEmpty) {
      return PaperErrorState(
        message: provider.error!,
        onRetry: () => provider.loadConfigVars(widget.appId),
      );
    }

    if (provider.configVars.isEmpty) {
      return PaperEmptyState(
        icon: Icons.key_outlined,
        title: 'No config vars',
        message: 'Environment variables you add will show up here.',
        action: widget.showFab
            ? PaperButton(
                label: 'Add variable',
                variant: PaperButtonVariant.accent,
                icon: Icons.add,
                onPressed: () => _showAddEditDialog(),
              )
            : null,
      );
    }

    final vars = _filtered(provider.configVars);
    if (vars.isEmpty) {
      return PaperEmptyState(
        icon: Icons.search_off,
        title: 'No matches',
        message: 'No config vars match "$_searchQuery".',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => provider.loadConfigVars(widget.appId),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          PaperTokens.l,
          PaperTokens.xs,
          PaperTokens.l,
          PaperTokens.xl,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: vars.length,
        itemBuilder: (context, index) {
          final entry = vars[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: PaperTokens.s),
            child: _ConfigVarCard(
              configKey: entry.key,
              configValue: entry.value,
              onEdit: () => _showAddEditDialog(
                existingKey: entry.key,
                existingValue: entry.value,
              ),
              onDelete: () => _confirmDelete(entry.key),
            ),
          );
        },
      ),
    );
  }
}

class _ConfigVarCard extends StatefulWidget {
  const _ConfigVarCard({
    required this.configKey,
    required this.configValue,
    required this.onEdit,
    required this.onDelete,
  });

  final String configKey;
  final String configValue;
  final VoidCallback onEdit;
  final Future<bool> Function() onDelete;

  @override
  State<_ConfigVarCard> createState() => _ConfigVarCardState();
}

class _ConfigVarCardState extends State<_ConfigVarCard> {
  bool _isVisible = false;

  String get _displayValue {
    if (_isVisible || widget.configValue.isEmpty) return widget.configValue;
    if (widget.configValue.length <= 4) return '••••';
    return '${widget.configValue.substring(0, 4)}'
        '${'•' * (widget.configValue.length - 4)}';
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.configValue));
    PaperSnack.show(context, 'Copied ${widget.configKey}');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Dismissible(
      key: Key(widget.configKey),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: c.error,
          borderRadius: BorderRadius.circular(PaperTokens.rCard),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: PaperTokens.l),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        await widget.onDelete();
        return false;
      },
      child: PaperCard(
        onTap: widget.onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaperCaption(widget.configKey),
            const SizedBox(height: PaperTokens.s),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _displayValue,
                    style: PaperText.mono.copyWith(color: c.muted),
                    maxLines: _isVisible ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: PaperTokens.s),
                PaperIconButton(
                  icon: _isVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 30,
                  tooltip: _isVisible ? 'Hide' : 'Show',
                  onPressed: () => setState(() => _isVisible = !_isVisible),
                ),
                const SizedBox(width: PaperTokens.xs),
                PaperIconButton(
                  icon: Icons.copy_outlined,
                  size: 30,
                  tooltip: 'Copy',
                  onPressed: _copy,
                ),
                const SizedBox(width: PaperTokens.xs),
                PaperIconButton(
                  icon: Icons.edit_outlined,
                  size: 30,
                  tooltip: 'Edit',
                  onPressed: widget.onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
