import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herokuandroid/core/constants/theme_constants.dart';
import 'package:herokuandroid/data/services/cache_service.dart';
import 'package:herokuandroid/presentation/providers/theme_provider.dart';

/// Settings screen for app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildAppearanceSection(context),
          const Divider(),
          _buildCacheSection(context),
          const Divider(),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(ThemeConstants.spacingM),
              child: Text(
                'Appearance',
                style: ThemeConstants.headingSmall.copyWith(
                  color: ThemeConstants.primaryAccent,
                ),
              ),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Theme'),
              subtitle: const Text('Use light theme'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
              secondary: const Icon(Icons.light_mode),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Theme'),
              subtitle: const Text('Use dark theme'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              subtitle: const Text('Follow system theme'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
              secondary: const Icon(Icons.settings_system_daydream),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCacheSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          child: Text(
            'Cache',
            style: ThemeConstants.headingSmall.copyWith(
              color: ThemeConstants.primaryAccent,
            ),
          ),
        ),
        ListTile(
          title: const Text('Clear Cache'),
          subtitle: const Text('Remove cached app data'),
          leading: const Icon(Icons.delete_sweep),
          onTap: () => _showClearCacheDialog(context),
        ),
      ],
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will remove all cached app data. Your apps will be reloaded from the server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Get CacheService from main.dart dependencies
              final cacheService = CacheService(
                await SharedPreferences.getInstance(),
              );

              await cacheService.clearAllCache();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          child: Text(
            'About',
            style: ThemeConstants.headingSmall.copyWith(
              color: ThemeConstants.primaryAccent,
            ),
          ),
        ),
        ListTile(
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
          leading: const Icon(Icons.info_outline),
        ),
        ListTile(
          title: const Text('HerokuDroid'),
          subtitle: const Text('Manage your Heroku apps with ease'),
          leading: const Icon(Icons.cloud),
        ),
      ],
    );
  }
}
