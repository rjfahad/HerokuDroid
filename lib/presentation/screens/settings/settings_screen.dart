import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/legal_urls.dart';
import '../../../core/theme/paper_colors.dart';
import '../../../core/theme/paper_tokens.dart';
import '../../../data/services/cache_service.dart';
import '../../providers/app_lock_provider.dart';
import '../../providers/apps_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/update_provider.dart';
import '../../widgets/paper/paper_components.dart';
import '../../widgets/paper/paper_snack.dart';
import '../../widgets/update/update_dialog.dart';

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
          _SecuritySection(),
          SizedBox(height: PaperTokens.m),
          _DashboardSection(),
          SizedBox(height: PaperTokens.m),
          _CacheSection(),
          SizedBox(height: PaperTokens.m),
          _AboutSection(),
          SizedBox(height: PaperTokens.m),
          _UpdatesSection(),
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

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Consumer<AppLockProvider>(
      builder: (context, lock, _) {
        return _SectionCard(
          caption: 'Security',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ToggleRow(
                title: 'App lock',
                subtitle: lock.lockEnabled
                    ? 'A password is required to open HerokuDroid'
                    : 'Protect your stored Heroku API key',
                value: lock.lockEnabled,
                onChanged: (value) => _toggleLock(context, lock, value),
              ),
              if (lock.lockEnabled) ...[
                Divider(height: PaperTokens.xl, color: c.line),
                _ToggleRow(
                  title: 'Use biometrics',
                  subtitle: lock.biometricsAvailable
                      ? 'Fingerprint or face unlock'
                      : 'Not available on this device',
                  value: lock.biometricsEnabled,
                  enabled: lock.biometricsAvailable,
                  onChanged: lock.setBiometricsEnabled,
                ),
                const SizedBox(height: PaperTokens.m),
                PaperButton(
                  label: 'Change password',
                  variant: PaperButtonVariant.outline,
                  size: PaperButtonSize.small,
                  icon: Icons.password_rounded,
                  onPressed: () => _changePassword(context, lock),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: PaperText.label.copyWith(
                  color: enabled ? c.ink : c.muted,
                ),
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
        Switch(value: value, onChanged: enabled ? onChanged : null),
      ],
    );
  }
}

Future<void> _toggleLock(
  BuildContext context,
  AppLockProvider lock,
  bool enable,
) async {
  if (!enable) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Turn off app lock?'),
        content: const Text(
          'HerokuDroid will open without asking for a password.',
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
            child: const Text('Turn off'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await lock.disableLock();
    if (context.mounted) PaperSnack.success(context, 'App lock turned off');
    return;
  }

  final password = await showPasswordDialog(
    context,
    title: 'Set app password',
    confirmLabel: 'Enable lock',
  );
  if (password == null) return;

  final ok = await lock.enableLock(password);
  if (!context.mounted) return;
  if (ok) {
    PaperSnack.success(context, 'App lock enabled');
  } else {
    PaperSnack.error(context, lock.error ?? 'Could not enable app lock');
  }
}

Future<void> _changePassword(BuildContext context, AppLockProvider lock) async {
  final password = await showPasswordDialog(
    context,
    title: 'Change app password',
    confirmLabel: 'Save',
  );
  if (password == null) return;

  final ok = await lock.changePassword(password);
  if (!context.mounted) return;
  if (ok) {
    PaperSnack.success(context, 'Password updated');
  } else {
    PaperSnack.error(context, lock.error ?? 'Could not update password');
  }
}

/// Prompt for a new app-lock password (entered twice). Returns the password or
/// null if cancelled.
Future<String?> showPasswordDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) =>
        _PasswordDialog(title: title, confirmLabel: confirmLabel),
  );
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.title, required this.confirmLabel});

  final String title;
  final String confirmLabel;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _password.text;
    if (password.length < AppConstants.appLockMinPasswordLength) {
      setState(
        () => _error =
            'Use at least ${AppConstants.appLockMinPasswordLength} characters.',
      );
      return;
    }
    if (password != _confirm.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaperTextField(
            controller: _password,
            obscureText: true,
            autofocus: true,
            hintText: 'Password',
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
          ),
          const SizedBox(height: PaperTokens.m),
          PaperTextField(
            controller: _confirm,
            obscureText: true,
            hintText: 'Confirm password',
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
          ),
          if (_error != null) ...[
            const SizedBox(height: PaperTokens.s),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: PaperText.bodySmall.copyWith(color: c.error),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
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

class _UpdatesSection extends StatelessWidget {
  const _UpdatesSection();

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Consumer<UpdateProvider>(
      builder: (context, updater, _) {
        final update = updater.availableUpdate;
        final version = updater.currentVersion.isEmpty
            ? AppConstants.version
            : updater.currentVersion;

        return _SectionCard(
          caption: 'Updates',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HerokuDroid $version',
                style: PaperText.label.copyWith(color: c.ink),
              ),
              const SizedBox(height: 2),
              Text(
                update != null
                    ? 'Version ${update.version} is available'
                    : "You're on the latest version",
                style: PaperText.bodySmall.copyWith(
                  color: update != null ? c.accent : c.muted,
                ),
              ),
              if (updater.error != null) ...[
                const SizedBox(height: PaperTokens.s),
                Text(
                  updater.error!,
                  style: PaperText.bodySmall.copyWith(color: c.error),
                ),
              ],
              const SizedBox(height: PaperTokens.m),
              Row(
                children: [
                  PaperButton(
                    label: 'Check for updates',
                    variant: PaperButtonVariant.outline,
                    size: PaperButtonSize.small,
                    icon: Icons.refresh,
                    loading: updater.isChecking,
                    onPressed: () => _checkForUpdates(context, updater),
                  ),
                  if (update != null) ...[
                    const SizedBox(width: PaperTokens.s),
                    PaperButton(
                      label: 'Update',
                      variant: PaperButtonVariant.accent,
                      size: PaperButtonSize.small,
                      icon: Icons.system_update_alt,
                      onPressed: () => showUpdateDialog(context, update),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _checkForUpdates(
  BuildContext context,
  UpdateProvider updater,
) async {
  final found = await updater.checkForUpdates();
  if (!context.mounted) return;

  if (updater.error != null) {
    PaperSnack.error(context, updater.error!);
  } else if (found) {
    await showUpdateDialog(context, updater.availableUpdate!);
  } else {
    PaperSnack.success(context, "You're on the latest version");
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
