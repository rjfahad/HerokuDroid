import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/legal_urls.dart';
import '../../../core/theme/paper_colors.dart';
import '../../../core/theme/paper_tokens.dart';
import '../../../data/services/cache_service.dart';
import '../../providers/apps_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/paper/paper_components.dart';
import '../../widgets/paper/paper_snack.dart';

/// Settings screen for app preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.paper.background,
      appBar: AppBar(centerTitle: true, title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PaperTokens.l,
          PaperTokens.s,
          PaperTokens.l,
          PaperTokens.xl,
        ),
        children: const [
          _AppearanceSection(),
          SizedBox(height: PaperTokens.m),
          _DashboardSection(),
          SizedBox(height: PaperTokens.m),
          _CacheSection(),
          SizedBox(height: PaperTokens.m),
          _AboutSection(),
          SizedBox(height: PaperTokens.m),
          _LegalSection(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.caption,
    required this.child,
  });

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaperCaption(caption),
          const SizedBox(height: PaperTokens.m),
          child,
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        const modes = [ThemeMode.light, ThemeMode.system, ThemeMode.dark];
        final index = modes.indexOf(themeProvider.themeMode).clamp(0, 2);
        return _SectionCard(
          caption: 'Appearance',
          child: _SegmentedControl(
            labels: const ['Light', 'System', 'Dark'],
            selectedIndex: index,
            onSelected: (i) => themeProvider.setThemeMode(modes[i]),
          ),
        );
      },
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection();

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Consumer<AppsProvider>(
      builder: (context, appsProvider, _) {
        return _SectionCard(
          caption: 'Dashboard',
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live app status',
                      style: PaperText.label.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Show running/stopped per app (extra requests)',
                      style: PaperText.bodySmall.copyWith(color: c.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PaperTokens.s),
              Switch(
                value: appsProvider.showLiveStatus,
                onChanged: appsProvider.setShowLiveStatus,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CacheSection extends StatelessWidget {
  const _CacheSection();

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return _SectionCard(
      caption: 'Cache',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cached app data makes launches faster.',
            style: PaperText.bodySmall.copyWith(color: c.muted),
          ),
          const SizedBox(height: PaperTokens.m),
          PaperButton(
            label: 'Clear cache',
            variant: PaperButtonVariant.destructive,
            icon: Icons.delete_sweep_outlined,
            onPressed: () => _confirmClearCache(context),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return _SectionCard(
      caption: 'About',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HerokuDroid',
            style: PaperText.h2.copyWith(color: c.ink),
          ),
          const SizedBox(height: 2),
          Text(
            'Version 1.0.0 · Heroku in your pocket',
            style: PaperText.bodySmall.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      caption: 'Legal',
      child: Column(
        children: [
          _LegalRow(
            title: 'Privacy Policy',
            subtitle: 'What the app stores and where it goes',
            url: LegalUrls.privacy,
          ),
          Divider(height: PaperTokens.xl, color: context.paper.line),
          _LegalRow(
            title: 'Terms of Service',
            subtitle: 'Rules for using HerokuDroid',
            url: LegalUrls.terms,
          ),
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.title,
    required this.subtitle,
    required this.url,
  });

  final String title;
  final String subtitle;
  final String url;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        PaperSnack.error(context, 'Could not open $url');
      }
    } catch (e) {
      if (context.mounted) PaperSnack.error(context, 'Failed to open: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return InkWell(
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PaperTokens.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PaperText.label.copyWith(color: c.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: PaperText.bodySmall.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PaperTokens.s),
            Icon(Icons.open_in_new, size: 18, color: c.muted),
          ],
        ),
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

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
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? c.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(PaperTokens.rPill),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: i == selectedIndex
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: i == selectedIndex ? c.background : c.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _confirmClearCache(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear cache?'),
      content: const Text(
        'This removes all cached app data. Your apps will be reloaded from the server.',
      ),
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
          child: const Text('Clear'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final cacheService = CacheService(await SharedPreferences.getInstance());
  await cacheService.clearAllCache();

  if (!context.mounted) return;
  PaperSnack.success(context, 'Cache cleared');
}
