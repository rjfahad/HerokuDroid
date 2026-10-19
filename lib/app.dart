import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokudroid/core/theme/paper_theme.dart';
import 'package:herokudroid/presentation/providers/app_lock_provider.dart';
import 'package:herokudroid/presentation/providers/auth_provider.dart';
import 'package:herokudroid/presentation/providers/theme_provider.dart';
import 'package:herokudroid/presentation/providers/update_provider.dart';
import 'package:herokudroid/presentation/screens/auth/lock_screen.dart';
import 'package:herokudroid/presentation/screens/auth/login_screen.dart';
import 'package:herokudroid/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:herokudroid/presentation/widgets/update/update_dialog.dart';

/// Root app widget
class HerokuDroidApp extends StatelessWidget {
  const HerokuDroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'HerokuDroid',
          debugShowCheckedModeBanner: false,
          theme: PaperTheme.light,
          darkTheme: PaperTheme.dark,
          themeMode: themeProvider.themeMode,
          home: const AuthCheck(),
        );
      },
    );
  }
}

/// Widget to check authentication status and route accordingly
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check auth, load security settings, and look for updates on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
      context.read<AppLockProvider>().init();
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final updater = context.read<UpdateProvider>();
    await updater.checkForUpdates(silent: true);
    if (!mounted || !updater.shouldPrompt) return;

    final updated = await showUpdateDialog(context, updater.availableUpdate!);
    if (!updated) await updater.dismissPrompt();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-lock when the app is backgrounded so the token isn't exposed.
    if (state == AppLifecycleState.paused) {
      context.read<AppLockProvider>().lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppLockProvider>(
      builder: (context, authProvider, lockProvider, _) {
        // Show loading while auth/security state resolves
        if (authProvider.isLoading || !lockProvider.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Lock only guards a signed-in account.
        if (lockProvider.isLocked) {
          return const LockScreen();
        }

        return const DashboardScreen();
      },
    );
  }
}
