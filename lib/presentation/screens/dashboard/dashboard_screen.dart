import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:herokudroid/core/constants/theme_constants.dart';
import 'package:herokudroid/presentation/providers/apps_provider.dart';
import 'package:herokudroid/presentation/providers/auth_provider.dart';
import 'package:herokudroid/presentation/screens/auth/login_screen.dart';
import 'package:herokudroid/presentation/screens/settings/settings_screen.dart';
import 'package:herokudroid/presentation/widgets/common/app_card.dart';
import 'package:herokudroid/presentation/widgets/common/empty_state_widget.dart';
import 'package:herokudroid/presentation/widgets/common/skeleton_widgets.dart';

/// Dashboard screen showing list of Heroku apps
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load apps when screen is first opened
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
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_icon.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text('HerokuDroid'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppsProvider>().refreshApps();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Header with app count and view toggle
          _buildHeader(),

          // Apps list
          Expanded(
            child: Consumer<AppsProvider>(
              builder: (context, appsProvider, _) {
                if (appsProvider.isLoading && !appsProvider.hasApps) {
                  // Show shimmer loading effect
                  return Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        top: ThemeConstants.spacingS,
                        bottom: ThemeConstants.spacingL,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) => const AppCardSkeleton(),
                    ),
                  );
                }

                if (appsProvider.error != null && !appsProvider.hasApps) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: ThemeConstants.iconSizeXl,
                          color: ThemeConstants.statusError,
                        ),
                        const SizedBox(height: ThemeConstants.spacingM),
                        Text(
                          appsProvider.error!,
                          style: ThemeConstants.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ThemeConstants.spacingL),
                        ElevatedButton(
                          onPressed: () {
                            appsProvider.loadApps();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!appsProvider.hasApps) {
                  return const EmptyStateWidget(
                    icon: Icons.cloud_off,
                    message: 'No apps found',
                    description: 'You don\'t have any Heroku apps yet.',
                  );
                }

                if (appsProvider.apps.isEmpty &&
                    appsProvider.searchQuery.isNotEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    message: 'No results found',
                    description: 'No apps match "${appsProvider.searchQuery}"',
                  );
                }

                return RefreshIndicator(
                  onRefresh: appsProvider.refreshApps,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive grid based on screen width
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      // Adjust aspect ratio based on screen size
                      final aspectRatio = constraints.maxWidth > 600
                          ? 1.3
                          : 1.4;

                      return GridView.builder(
                        padding: const EdgeInsets.only(
                          top: ThemeConstants.spacingS,
                          bottom: ThemeConstants.spacingL,
                          left: ThemeConstants.spacingS,
                          right: ThemeConstants.spacingS,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: ThemeConstants.spacingS,
                          mainAxisSpacing: ThemeConstants.spacingS,
                        ),
                        itemCount: appsProvider.apps.length,
                        itemBuilder: (context, index) {
                          final app = appsProvider.apps[index];
                          return AppCard(app: app, isGridView: true);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AppsProvider>(
      builder: (context, appsProvider, _) {
        final appCount = appsProvider.apps.length;
        final totalCount = appsProvider.allApps.length;
        final isFiltered = appsProvider.searchQuery.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // App count
              Text(
                isFiltered
                    ? 'My Apps ($appCount of $totalCount)'
                    : 'My Apps ($appCount)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ThemeConstants.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: const Border(
          bottom: BorderSide(color: ThemeConstants.dividerColor, width: 1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search apps...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: Consumer<AppsProvider>(
            builder: (context, appsProvider, _) {
              if (appsProvider.searchQuery.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  context.read<AppsProvider>().clearSearch();
                },
              );
            },
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingM,
            vertical: ThemeConstants.spacingS,
          ),
        ),
        onChanged: (value) {
          context.read<AppsProvider>().setSearchQuery(value);
        },
      ),
    );
  }
}
