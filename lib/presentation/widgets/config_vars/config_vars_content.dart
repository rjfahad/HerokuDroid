import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:herokuandroid/presentation/providers/config_provider.dart';
import 'package:herokuandroid/presentation/widgets/common/error_widget.dart'
    as custom;
import 'package:herokuandroid/presentation/widgets/common/skeleton_widgets.dart';

/// Reusable widget for displaying and managing config vars
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigProvider>().loadConfigVars(widget.appId);
    });
  }

  List<MapEntry<String, String>> _getFilteredConfigVars(
    Map<String, String> configVars,
  ) {
    if (_searchQuery.isEmpty) {
      return configVars.entries.toList();
    }
    return configVars.entries.where((entry) {
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.value.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showAddEditDialog({String? existingKey, String? existingValue}) {
    final keyController = TextEditingController(text: existingKey);
    final valueController = TextEditingController(text: existingValue);
    final formKey = GlobalKey<FormState>();
    final isEditing = existingKey != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Config Var' : 'Add Config Var'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: keyController,
                enabled: !isEditing, // Key is immutable when editing
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
              const SizedBox(height: 16),
              TextFormField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  hintText: 'postgres://...',
                ),
                maxLines: 3,
                validator: (value) {
                  // Value can be empty for some config vars
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                final success = await context
                    .read<ConfigProvider>()
                    .setConfigVar(
                      widget.appId,
                      keyController.text.trim(),
                      valueController.text.trim(),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '${isEditing ? 'Updated' : 'Added'} ${keyController.text}'
                            : 'Failed to ${isEditing ? 'update' : 'add'} config var',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String key) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Config Var'),
        content: Text('Are you sure you want to delete "$key"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<ConfigProvider>().deleteConfigVar(
        widget.appId,
        key,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Deleted $key' : 'Failed to delete config var',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar - doesn't need to rebuild when provider changes
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search config vars',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Content - use Consumer to only rebuild this part
          Expanded(
            child: Consumer<ConfigProvider>(
              builder: (context, provider, child) => _buildContent(provider),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.showFab
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              tooltip: 'Add Config Var',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildContent(ConfigProvider provider) {
    if (provider.isLoading) {
      // Show shimmer loading effect
      return Skeletonizer(
        enabled: true,
        child: ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) => const ConfigVarSkeleton(),
        ),
      );
    }

    if (provider.error != null) {
      return custom.ErrorWidget(
        message: provider.error!,
        onRetry: () => provider.loadConfigVars(widget.appId),
      );
    }

    if (provider.configVars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No config vars',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add environment variables for your app',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final filteredVars = _getFilteredConfigVars(provider.configVars);

    if (filteredVars.isEmpty) {
      return Center(
        child: Text(
          'No config vars match "$_searchQuery"',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Add pull-to-refresh
    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadConfigVars(widget.appId);
      },
      child: ListView.builder(
        itemCount: filteredVars.length,
        itemBuilder: (context, index) {
          final entry = filteredVars[index];
          return ConfigVarItem(
            configKey: entry.key,
            configValue: entry.value,
            onEdit: () => _showAddEditDialog(
              existingKey: entry.key,
              existingValue: entry.value,
            ),
            onDelete: () => _confirmDelete(entry.key),
          );
        },
      ),
    );
  }
}

/// Widget for displaying a single config var with masked value
class ConfigVarItem extends StatefulWidget {
  final String configKey;
  final String configValue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ConfigVarItem({
    required this.configKey,
    required this.configValue,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  State<ConfigVarItem> createState() => _ConfigVarItemState();
}

class _ConfigVarItemState extends State<ConfigVarItem> {
  bool _isVisible = false;

  String get _displayValue {
    if (_isVisible) return widget.configValue;
    // Mask value (show first 4 chars, rest as dots)
    if (widget.configValue.length <= 4) return '••••';
    return '${widget.configValue.substring(0, 4)}${'•' * (widget.configValue.length - 4)}';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.configValue));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${widget.configKey} to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.configKey),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        widget.onDelete();
        return false; // Don't auto-dismiss, let the delete callback handle it
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          title: Text(
            widget.configKey,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayValue,
                    style: const TextStyle(fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                    maxLines: _isVisible ? 3 : 1,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  iconSize: 20,
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  tooltip: _isVisible ? 'Hide' : 'Show',
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  iconSize: 20,
                  onPressed: _copyToClipboard,
                  tooltip: 'Copy',
                ),
              ],
            ),
          ),
          onTap: widget.onEdit,
          onLongPress: widget.onEdit,
        ),
      ),
    );
  }
}
