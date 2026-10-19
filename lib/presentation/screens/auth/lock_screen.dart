import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/presentation/providers/app_lock_provider.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';

/// Shown over the app when the lock is engaged. Unlocks with the app password
/// or biometrics (when enabled).
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  bool _autoPrompted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _autoPromptBiometrics(),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _autoPromptBiometrics() {
    if (_autoPrompted || !mounted) return;
    final lock = context.read<AppLockProvider>();
    if (!lock.biometricsEnabled || !lock.biometricsAvailable) return;
    _autoPrompted = true;
    lock.unlockWithBiometrics();
  }

  Future<void> _unlockWithPassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) return;
    final ok = await context.read<AppLockProvider>().unlockWithPassword(
      password,
    );
    if (ok) _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.paper;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Consumer<AppLockProvider>(
                builder: (context, lock, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Icon(Icons.lock_outline_rounded, size: 40, color: c.ink),
                      const SizedBox(height: PaperTokens.m),
                      Text(
                        'Locked',
                        textAlign: TextAlign.center,
                        style: PaperText.hero.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: PaperTokens.s),
                      Text(
                        'Unlock to reach your Heroku account.',
                        textAlign: TextAlign.center,
                        style: PaperText.body.copyWith(color: c.muted),
                      ),
                      const SizedBox(height: PaperTokens.xl),
                      PaperTextField(
                        controller: _passwordController,
                        obscureText: true,
                        hintText: 'App password',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _unlockWithPassword(),
                        prefixIcon: const Icon(
                          Icons.password_rounded,
                          size: 18,
                        ),
                      ),
                      if (lock.error != null) ...[
                        const SizedBox(height: PaperTokens.s),
                        Text(
                          lock.error!,
                          style: PaperText.bodySmall.copyWith(color: c.error),
                        ),
                      ],
                      const SizedBox(height: PaperTokens.m),
                      PaperButton(
                        label: 'Unlock',
                        variant: PaperButtonVariant.accent,
                        expand: true,
                        loading: lock.isAuthenticating,
                        onPressed: _unlockWithPassword,
                      ),
                      if (lock.biometricsEnabled &&
                          lock.biometricsAvailable) ...[
                        const SizedBox(height: PaperTokens.m),
                        PaperButton(
                          label: 'Use biometrics',
                          variant: PaperButtonVariant.outline,
                          icon: Icons.fingerprint_rounded,
                          expand: true,
                          loading: lock.isAuthenticating,
                          onPressed: lock.unlockWithBiometrics,
                        ),
                      ],
                      const Spacer(flex: 2),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
