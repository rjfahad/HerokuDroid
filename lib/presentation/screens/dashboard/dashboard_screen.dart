import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokuandroid/core/constants/theme_constants.dart';
import 'package:herokuandroid/presentation/providers/apps_provider.dart';
import 'package:herokuandroid/presentation/providers/auth_provider.dart';
import 'package:herokuandroid/presentation/screens/auth/login_screen.dart';
import 'package:herokuandroid/presentation/screens/settings/settings_screen.dart';
import 'package:herokuandroid/presentation/widgets/common/app_card.dart';
import 'package:herokuandroid/presentation/widgets/common/empty_state_widget.dart';
import 'package:herokuandroid/presentation/widgets/common/loading_widget.dart';

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
        title: const Text('HerokuDroid'),
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

          // Apps list
          Expanded(
            child: Consumer<AppsProvider>(
              builder: (context, appsProvider, _) {
                if (appsProvider.isLoading && !appsProvider.hasApps) {
                  return const LoadingWidget(message: 'Loading apps...');
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
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: ThemeConstants.spacingS,
                      bottom: ThemeConstants.spacingL,
                    ),
                    itemCount: appsProvider.apps.length,
                    itemBuilder: (context, index) {
                      final app = appsProvider.apps[index];
                      return AppCard(app: app);
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search apps...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Consumer<AppsProvider>(
            builder: (context, appsProvider, _) {
              if (appsProvider.searchQuery.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.clear),
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
