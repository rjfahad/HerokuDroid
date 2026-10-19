import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/data/models/log_entry.dart';
import 'package:herokudroid/presentation/providers/log_provider.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';

const Color _kInfoColor = Color(0xFF8FB4FF);
const Color _kSourceColor = Color(0xFFB7A8FF);

/// Screen for viewing real-time application logs.
class LogsScreen extends StatefulWidget {
  final String appId;
  final String appName;
  final bool showAppBar;

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
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    _logProvider.disconnect();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final isAtBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50;
    if (!isAtBottom && _autoScroll) {
      setState(() => _autoScroll = false);
    } else if (isAtBottom && !_autoScroll) {
      setState(() => _autoScroll = true);
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
    if (_levelFilter != null && log.level != _levelFilter) return false;
    if (_sourceFilter != null && log.source != _sourceFilter) return false;
    if (_dynoFilter != null && log.dyno != _dynoFilter) return false;
    return true;
  }

  bool get _hasFilters =>
      _levelFilter != null || _sourceFilter != null || _dynoFilter != null;

  String _formatCount(int count) => NumberFormat.decimalPattern().format(count);

  void _clearFilters() => setState(() {
    _levelFilter = null;
    _sourceFilter = null;
    _dynoFilter = null;
  });

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        _buildToolbar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PaperTokens.l,
            PaperTokens.xs,
            PaperTokens.l,
            PaperTokens.s,
          ),
          child: PaperTextField(
            controller: _searchController,
            hintText: 'Search logs',
            prefixIcon: const Icon(Icons.search, size: 20),
            onChanged: (value) => setState(() => _searchQuery = value),
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
        _buildFilterChips(),
        Expanded(
          child: Consumer<LogProvider>(
            builder: (context, provider, _) {
              final filtered = provider.logs.where(_matchesFilters).toList();

              if (_autoScroll && filtered.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }

              return Column(
                children: [
                  Expanded(
                    child: _Terminal(
                      controller: _scrollController,
                      child: _terminalChild(provider, filtered),
                    ),
                  ),
                  if (!_autoScroll && filtered.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: PaperTokens.l),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _autoScroll = true);
                          _scrollToBottom();
                        },
                        child: const PaperTag(
                          label: '↓  Jump to latest',
                          variant: PaperTagVariant.accent,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: context.paper.background,
      appBar: widget.showAppBar
          ? AppBar(title: Text('${widget.appName} Logs'))
          : null,
      body: body,
    );
  }

  Widget _terminalChild(LogProvider provider, List<LogEntry> filtered) {
    if (provider.state == LogConnectionState.error) {
      return _TerminalMessage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Connection error',
              style: TextStyle(
                color: _kInfoColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: PaperTokens.s),
            Text(
              provider.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    context.paper.onContrast.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: PaperTokens.l),
            PaperButton(
              label: 'Retry',
              variant: PaperButtonVariant.accent,
              size: PaperButtonSize.small,
              icon: Icons.refresh,
              onPressed: () => provider.connect(widget.appId, lines: 100),
            ),
          ],
        ),
      );
    }

    if (provider.state == LogConnectionState.disconnected) {
      return _TerminalMessage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.terminal,
              size: 40,
              color: context.paper.onContrast.withValues(alpha: 0.4),
            ),
            const SizedBox(height: PaperTokens.m),
            Text(
              'Not connected',
              style: TextStyle(
                color: context.paper.onContrast,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PaperTokens.xs),
            Text(
              'Start streaming logs for this app.',
              style: TextStyle(
                color: context.paper.onContrast.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.state == LogConnectionState.connecting && filtered.isEmpty) {
      return _TerminalMessage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: PaperTokens.m),
            Text(
              'Connecting to log stream…',
              style: TextStyle(
                color: context.paper.onContrast.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return _TerminalMessage(
        child: Text(
          'No logs match the current filters',
          style: TextStyle(
            color: context.paper.onContrast.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(PaperTokens.m),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _LogLine(log: filtered[index]),
    );
  }

  Widget _buildToolbar() {
    return Consumer<LogProvider>(
      builder: (context, provider, _) {
        final hasLogs = provider.logs.isNotEmpty;
        final isConnected = provider.state == LogConnectionState.connected;
        final isPaused = provider.state == LogConnectionState.paused;
        final isConnecting = provider.state == LogConnectionState.connecting;
        final isIdle =
            provider.state == LogConnectionState.disconnected ||
            provider.state == LogConnectionState.error;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            PaperTokens.l,
            PaperTokens.s,
            PaperTokens.l,
            0,
          ),
          child: Row(
            children: [
              _stateTag(provider.state),
              const SizedBox(width: PaperTokens.s),
              Text(
                '${_formatCount(provider.logs.length)} lines',
                style: PaperText.bodySmall.copyWith(
                  color: context.paper.muted,
                ),
              ),
              const Spacer(),
              if (isConnected)
                PaperIconButton(
                  icon: Icons.pause,
                  size: 34,
                  tooltip: 'Pause',
                  onPressed: provider.pause,
                ),
              if (isPaused)
                PaperIconButton(
                  icon: Icons.play_arrow,
                  size: 34,
                  tooltip: 'Resume',
                  onPressed: provider.resume,
                ),
              if (hasLogs) ...[
                const SizedBox(width: PaperTokens.xs),
                PaperIconButton(
                  icon: Icons.backspace_outlined,
                  size: 34,
                  tooltip: 'Clear',
                  onPressed: provider.clearLogs,
                ),
              ],
              if (isIdle && !isConnecting) ...[
                const SizedBox(width: PaperTokens.xs),
                PaperButton(
                  label: 'Connect',
                  variant: PaperButtonVariant.accent,
                  size: PaperButtonSize.small,
                  icon: Icons.play_arrow,
                  onPressed: () => provider.connect(widget.appId, lines: 100),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  PaperTag _stateTag(LogConnectionState state) {
    return switch (state) {
      LogConnectionState.connected => const PaperTag(
        label: 'live',
        variant: PaperTagVariant.success,
        dot: true,
      ),
      LogConnectionState.connecting => const PaperTag(
        label: 'connecting',
        variant: PaperTagVariant.warning,
        dot: true,
      ),
      LogConnectionState.paused => const PaperTag(
        label: 'paused',
        variant: PaperTagVariant.accent,
        dot: true,
      ),
      LogConnectionState.error => const PaperTag(
        label: 'error',
        variant: PaperTagVariant.error,
        dot: true,
      ),
      LogConnectionState.disconnected => const PaperTag(label: 'offline'),
    };
  }

  Widget _buildFilterChips() {
    final provider = context.watch<LogProvider>();
    final sources = <String>{
      for (final log in provider.logs)
        if (log.source.isNotEmpty && log.source != 'app') log.source,
    }.take(3).toList();
    final dynos = <String>{
      for (final log in provider.logs)
        if (log.dyno != null) log.dyno!,
    }.take(3).toList();

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PaperTokens.l),
        children: [
          PaperChip(
            label: 'All',
            selected: !_hasFilters,
            onTap: _clearFilters,
          ),
          const SizedBox(width: PaperTokens.s),
          PaperChip(
            label: 'Error',
            selected: _levelFilter == LogLevel.error,
            onTap: () => setState(() {
              _levelFilter = _levelFilter == LogLevel.error
                  ? null
                  : LogLevel.error;
            }),
          ),
          const SizedBox(width: PaperTokens.s),
          PaperChip(
            label: 'Warn',
            selected: _levelFilter == LogLevel.warning,
            onTap: () => setState(() {
              _levelFilter = _levelFilter == LogLevel.warning
                  ? null
                  : LogLevel.warning;
            }),
          ),
          for (final source in sources) ...[
            const SizedBox(width: PaperTokens.s),
            PaperChip(
              label: source,
              selected: _sourceFilter == source,
              onTap: () => setState(() {
                _sourceFilter = _sourceFilter == source ? null : source;
              }),
            ),
          ],
          for (final dyno in dynos) ...[
            const SizedBox(width: PaperTokens.s),
            PaperChip(
              label: dyno,
              selected: _dynoFilter == dyno,
              onTap: () => setState(() {
                _dynoFilter = _dynoFilter == dyno ? null : dyno;
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _Terminal extends StatelessWidget {
  const _Terminal({required this.child, this.controller});

  final Widget child;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PaperTokens.l,
        PaperTokens.xs,
        PaperTokens.l,
        PaperTokens.l,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PaperTokens.rCard - 2),
        child: Container(
          width: double.infinity,
          color: context.paper.contrast,
          child: child,
        ),
      ),
    );
  }
}

class _TerminalMessage extends StatelessWidget {
  const _TerminalMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(child: child);
}

class _LogLine extends StatelessWidget {
  const _LogLine({required this.log});

  final LogEntry log;

  Color get _levelColor => switch (log.level) {
    LogLevel.error => const Color(0xFFFF8B7D),
    LogLevel.warning => const Color(0xFFF4C76B),
    LogLevel.info => _kInfoColor,
  };

  String get _time {
    final h = log.timestamp.hour.toString().padLeft(2, '0');
    final m = log.timestamp.minute.toString().padLeft(2, '0');
    final s = log.timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _levelLabel => switch (log.level) {
    LogLevel.error => 'ERROR',
    LogLevel.warning => 'WARN',
    LogLevel.info => 'INFO',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final dim = c.onContrast.withValues(alpha: 0.45);
    final source = log.dyno ?? log.source;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SelectableText.rich(
        TextSpan(
          style: PaperText.mono.copyWith(
            fontSize: 11.5,
            height: 1.5,
            color: c.onContrast,
          ),
          children: [
            TextSpan(text: '$_time ', style: TextStyle(color: dim)),
            TextSpan(
              text: '$source ',
              style: const TextStyle(color: _kSourceColor),
            ),
            TextSpan(
              text: '$_levelLabel ',
              style: TextStyle(color: _levelColor, fontWeight: FontWeight.w600),
            ),
            TextSpan(text: log.message),
          ],
        ),
      ),
    );
  }
}
