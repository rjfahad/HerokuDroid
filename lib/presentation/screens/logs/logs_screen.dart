import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokuandroid/data/models/log_entry.dart';
import 'package:herokuandroid/presentation/providers/log_provider.dart';

/// Screen for viewing real-time application logs
class LogsScreen extends StatefulWidget {
  final String appId;
  final String appName;
  final bool showAppBar; // Whether to show app bar (false when embedded in tab)

  const LogsScreen({
    super.key,
    required this.appId,
    required this.appName,
    this.showAppBar = true,
  });

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  String _searchQuery = '';
  LogLevel? _levelFilter;
  String? _sourceFilter;
  String? _dynoFilter;
  late LogProvider _logProvider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _logProvider = context.read<LogProvider>();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    // Disconnect when leaving screen
    _logProvider.disconnect();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.hasClients) {
      final isAtBottom =
          _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;

      if (!isAtBottom && _autoScroll) {
        setState(() => _autoScroll = false);
      } else if (isAtBottom && !_autoScroll) {
        setState(() => _autoScroll = true);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  bool _matchesFilters(LogEntry log) {
    if (_searchQuery.isNotEmpty &&
        !log.message.toLowerCase().contains(_searchQuery.toLowerCase())) {
      return false;
    }
    if (_levelFilter != null && log.level != _levelFilter) {
      return false;
    }
    if (_sourceFilter != null && log.source != _sourceFilter) {
      return false;
    }
    if (_dynoFilter != null && log.dyno != _dynoFilter) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        _buildConnectionControls(),
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: Consumer<LogProvider>(
            builder: (context, provider, _) {
              if (provider.state == LogConnectionState.error) {
                return _buildErrorState(provider.error ?? 'Unknown error');
              }

              final filteredLogs = provider.logs
                  .where(_matchesFilters)
                  .toList();

              if (filteredLogs.isEmpty) {
                return _buildEmptyState(provider.state);
              }

              // Auto-scroll when new logs arrive
              if (_autoScroll) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) {
                  return LogEntryWidget(log: filteredLogs[index]);
                },
              );
            },
          ),
        ),
      ],
    );

    if (!widget.showAppBar) {
      // When embedded in tab, return body with FAB wrapped in Scaffold
      return Scaffold(
        body: body,
        floatingActionButton: !_autoScroll
            ? FloatingActionButton.small(
                onPressed: () {
                  setState(() => _autoScroll = true);
                  _scrollToBottom();
                },
                tooltip: 'Resume auto-scroll',
                child: const Icon(Icons.arrow_downward),
              )
            : null,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.appName} Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter logs',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              context.read<LogProvider>().clearLogs();
            },
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: body,
      floatingActionButton: !_autoScroll
          ? FloatingActionButton.small(
              onPressed: () {
                setState(() => _autoScroll = true);
                _scrollToBottom();
              },
              tooltip: 'Resume auto-scroll',
              child: const Icon(Icons.arrow_downward),
            )
          : null,
    );
  }

  Widget _buildConnectionControls() {
    return Consumer<LogProvider>(
      builder: (context, provider, _) {
        final isConnected = provider.state == LogConnectionState.connected;
        final isPaused = provider.state == LogConnectionState.paused;
        final isConnecting = provider.state == LogConnectionState.connecting;

        return Container(
          padding: const EdgeInsets.all(8),
          color: _getConnectionColor(provider.state).withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                _getConnectionIcon(provider.state),
                color: _getConnectionColor(provider.state),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getConnectionText(provider.state),
                style: TextStyle(
                  color: _getConnectionColor(provider.state),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (!isConnected && !isPaused && !isConnecting)
                ElevatedButton.icon(
                  onPressed: () => provider.connect(widget.appId, lines: 100),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Connect'),
                ),
              if (isConnected)
                IconButton(
                  onPressed: provider.pause,
                  icon: const Icon(Icons.pause),
                  tooltip: 'Pause',
                ),
              if (isPaused)
                IconButton(
                  onPressed: provider.resume,
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Resume',
                ),
              if (isConnected || isPaused)
                IconButton(
                  onPressed: provider.disconnect,
                  icon: const Icon(Icons.stop),
                  tooltip: 'Disconnect',
                  color: Colors.red,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search logs...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    final hasFilters =
        _levelFilter != null || _sourceFilter != null || _dynoFilter != null;

    if (!hasFilters) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (_levelFilter != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Level: ${_levelFilter!.name}'),
                onDeleted: () => setState(() => _levelFilter = null),
                backgroundColor: _getLevelColor(_levelFilter!).withOpacity(0.2),
              ),
            ),
          if (_sourceFilter != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Source: $_sourceFilter'),
                onDeleted: () => setState(() => _sourceFilter = null),
              ),
            ),
          if (_dynoFilter != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Dyno: $_dynoFilter'),
                onDeleted: () => setState(() => _dynoFilter = null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LogConnectionState state) {
    if (state == LogConnectionState.disconnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Not connected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Press Connect to start streaming logs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (state == LogConnectionState.connecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to log stream...'),
          ],
        ),
      );
    }

    return Center(
      child: Text(
        'No logs match current filters',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LogProvider>().connect(widget.appId, lines: 100);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Logs'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Log Level:'),
              Wrap(
                spacing: 8,
                children: LogLevel.values.map((level) {
                  return FilterChip(
                    label: Text(level.name),
                    selected: _levelFilter == level,
                    selectedColor: _getLevelColor(level).withOpacity(0.3),
                    onSelected: (selected) {
                      setState(() {
                        _levelFilter = selected ? level : null;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Clear all filters:'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _levelFilter = null;
                    _sourceFilter = null;
                    _dynoFilter = null;
                  });
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getConnectionColor(LogConnectionState state) {
    switch (state) {
      case LogConnectionState.connected:
        return Colors.green;
      case LogConnectionState.connecting:
        return Colors.orange;
      case LogConnectionState.paused:
        return Colors.blue;
      case LogConnectionState.error:
        return Colors.red;
      case LogConnectionState.disconnected:
        return Colors.grey;
    }
  }

  IconData _getConnectionIcon(LogConnectionState state) {
    switch (state) {
      case LogConnectionState.connected:
        return Icons.check_circle;
      case LogConnectionState.connecting:
        return Icons.sync;
      case LogConnectionState.paused:
        return Icons.pause_circle;
      case LogConnectionState.error:
        return Icons.error;
      case LogConnectionState.disconnected:
        return Icons.cloud_off;
    }
  }

  String _getConnectionText(LogConnectionState state) {
    switch (state) {
      case LogConnectionState.connected:
        return 'Connected';
      case LogConnectionState.connecting:
        return 'Connecting...';
      case LogConnectionState.paused:
        return 'Paused';
      case LogConnectionState.error:
        return 'Error';
      case LogConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.info:
        return Colors.blue;
    }
  }
}

/// Widget for displaying a single log entry
class LogEntryWidget extends StatelessWidget {
  final LogEntry log;

  const LogEntryWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: _getLevelColor(log.level), width: 4),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getLevelColor(log.level).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.level.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(log.level),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                log.source,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (log.dyno != null) ...[
                const SizedBox(width: 4),
                Text(
                  '[${log.dyno}]',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const Spacer(),
              Text(
                _formatTimestamp(log.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            log.message,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.info:
        return Colors.blue;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
