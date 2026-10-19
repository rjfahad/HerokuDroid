import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/data/models/app.dart';
import 'package:herokudroid/presentation/providers/apps_provider.dart';
import 'package:herokudroid/presentation/providers/auth_provider.dart';
import 'package:herokudroid/presentation/screens/auth/login_screen.dart';
import 'package:herokudroid/presentation/screens/settings/settings_screen.dart';
import 'package:herokudroid/presentation/widgets/common/app_card.dart';
import 'package:herokudroid/presentation/widgets/common/skeleton_widgets.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';

enum _ViewMode { list, grid }

enum _StatusFilter { all, running, stopped }

/// Dashboard (home) — Design B (Paper).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  _ViewMode _viewMode = _ViewMode.list;
  _StatusFilter _filter = _StatusFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppsProvider>().loadApps();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: context.paper.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  List<App> _applyFilter(List<App> apps) {
    switch (_filter) {
      case _StatusFilter.all:
        return apps;
      case _StatusFilter.running:
        return apps.where((a) => (a.runningDynos ?? 0) > 0).toList();
      case _StatusFilter.stopped:
        return apps.where((a) => a.totalDynos == 0).toList();
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<AppsProvider>(
                builder: (context, appsProvider, _) {
                  return RefreshIndicator(
                    onRefresh: appsProvider.refreshApps,
                    color: context.paper.accent,
                    backgroundColor: context.paper.card,
                    child: _buildScrollBody(appsProvider),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final c = context.paper;
    return Consumer<AppsProvider>(
      builder: (context, appsProvider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaperCaption(_greeting),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('My apps', style: PaperText.h1.copyWith(color: c.ink)),
                        const SizedBox(width: 8),
                        Text(
                          '${appsProvider.allApps.length}',
                          style: PaperText.h1.copyWith(
                            fontSize: 18,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PaperIconButton(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              const SizedBox(width: 8),
              PaperIconButton(
                icon: Icons.power_settings_new_rounded,
                tooltip: 'Log out',
                onPressed: _handleLogout,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollBody(AppsProvider appsProvider) {
    if (appsProvider.isLoading && !appsProvider.hasApps) {
      return _skeletonScroll();
    }
    if (appsProvider.error != null && !appsProvider.hasApps) {
      return _messageScroll(
        icon: Icons.cloud_off_rounded,
        title: 'Couldn’t load your apps',
        message: appsProvider.error!,
        onRetry: appsProvider.loadApps,
      );
    }
    if (!appsProvider.hasApps) {
      return _messageScroll(
        icon: Icons.cloud_off_rounded,
        title: 'No apps yet',
        message: 'Apps you create on Heroku will appear here.',
        onRetry: appsProvider.loadApps,
      );
    }

    final apps = _applyFilter(appsProvider.apps);
    final searching = appsProvider.searchQuery.isNotEmpty;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildStats(
            appsProvider.allApps,
            appsProvider.showLiveStatus,
          ),
        ),
        SliverToBoxAdapter(child: _buildSearchRow(appsProvider)),
        SliverToBoxAdapter(child: _buildFilterChips()),
        if (apps.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _inlineEmpty(searching),
          )
        else if (_viewMode == _ViewMode.grid)
          _buildGrid(apps, appsProvider)
        else
          _buildList(apps, appsProvider),
        if (_viewMode == _ViewMode.list && apps.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Text(
                'Swipe a card for Rename · Delete',
                textAlign: TextAlign.center,
                style: PaperText.bodySmall.copyWith(color: context.paper.muted),
              ),
            ),
          )
        else
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildStats(List<App> apps, bool visible) {
    if (!visible) return const SizedBox.shrink();

    final running = apps.where((a) => (a.runningDynos ?? 0) > 0).length;
    final stopped = apps.where((a) => a.totalDynos == 0).length;
    final dynos = apps.fold<int>(0, (sum, a) => sum + (a.totalDynos ?? 0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Row(
        children: [
          Expanded(child: _statCard('$running', 'running')),
          const SizedBox(width: 8),
          Expanded(child: _statCard('$stopped', 'stopped')),
          const SizedBox(width: 8),
          Expanded(child: _statCard('$dynos', 'dynos')),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    final c = context.paper;
    return PaperCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: PaperText.h2.copyWith(fontSize: 22, color: c.ink)),
          const SizedBox(height: 2),
          Text(label, style: PaperText.bodySmall.copyWith(color: c.muted)),
        ],
      ),
    );
  }

  Widget _buildSearchRow(AppsProvider appsProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: PaperTextField(
              controller: _searchController,
              hintText: 'Search apps',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              onChanged: appsProvider.setSearchQuery,
              suffix: appsProvider.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        appsProvider.clearSearch();
                      },
                    ),
            ),
          ),
          const SizedBox(width: 10),
          _ViewToggle(
            mode: _viewMode,
            onChanged: (mode) => setState(() => _viewMode = mode),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Row(
        children: [
          PaperChip(
            label: 'All',
            selected: _filter == _StatusFilter.all,
            onTap: () => setState(() => _filter = _StatusFilter.all),
          ),
          const SizedBox(width: 6),
          PaperChip(
            label: 'Running',
            selected: _filter == _StatusFilter.running,
            onTap: () => setState(() => _filter = _StatusFilter.running),
          ),
          const SizedBox(width: 6),
          PaperChip(
            label: 'Stopped',
            selected: _filter == _StatusFilter.stopped,
            onTap: () => setState(() => _filter = _StatusFilter.stopped),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<App> apps, AppsProvider appsProvider) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      sliver: SliverList.separated(
        itemCount: apps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final app = apps[index];
          _scheduleEnrich(appsProvider, app);
          return AppCard(app: app);
        },
      ),
    );
  }

  Widget _buildGrid(List<App> apps, AppsProvider appsProvider) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 96,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final app = apps[index];
            _scheduleEnrich(appsProvider, app);
            return AppCard(app: app, isGridView: true);
          },
          childCount: apps.length,
        ),
      ),
    );
  }

  /// Lazily fetch status for a card that has none yet (large accounts). No-op
  /// once a summary exists or when live status is disabled.
  void _scheduleEnrich(AppsProvider appsProvider, App app) {
    if (app.totalDynos != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appsProvider.requestEnrichment(app.id);
    });
  }

  Widget _inlineEmpty(bool searching) {
    final c = context.paper;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 40, 18, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searching ? Icons.search_off_rounded : Icons.inbox_rounded,
            size: 40,
            color: c.muted,
          ),
          const SizedBox(height: 12),
          Text(
            searching ? 'No matching apps' : 'Nothing here',
            style: PaperText.h2.copyWith(color: c.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            searching
                ? 'Try a different search or filter.'
                : 'No apps match this filter.',
            style: PaperText.body.copyWith(color: c.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _skeletonScroll() {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildStats(const [], true)),
          SliverToBoxAdapter(child: _buildSearchRow(context.read<AppsProvider>())),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            sliver: SliverList.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => const AppCardSkeleton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageScroll({
    required IconData icon,
    required String title,
    required String message,
    required Future<void> Function() onRetry,
  }) {
    final c = context.paper;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      children: [
        Icon(icon, size: 44, color: c.muted),
        const SizedBox(height: 16),
        Text(
          title,
          style: PaperText.h2.copyWith(color: c.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: PaperText.body.copyWith(color: c.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Center(
          child: PaperButton(
            label: 'Retry',
            variant: PaperButtonVariant.accent,
            onPressed: () => onRetry(),
          ),
        ),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.mode, required this.onChanged});

  final _ViewMode mode;
  final ValueChanged<_ViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(PaperTokens.rPill),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          _toggleButton(context, Icons.menu_rounded, _ViewMode.list),
          _toggleButton(context, Icons.grid_view_rounded, _ViewMode.grid),
        ],
      ),
    );
  }

  Widget _toggleButton(BuildContext context, IconData icon, _ViewMode value) {
    final c = context.paper;
    final selected = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(PaperTokens.rPill),
        ),
        child: Icon(
          icon,
          size: 16,
          color: selected ? c.background : c.muted,
        ),
      ),
    );
  }
}
