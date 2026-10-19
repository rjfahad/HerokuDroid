import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';
import 'package:herokudroid/presentation/providers/auth_provider.dart';
import 'package:herokudroid/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:herokudroid/presentation/widgets/paper/paper_components.dart';

/// Login screen — Design B (Paper).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tokenController = TextEditingController();
  bool _obscureToken = true;
  String? _localError;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _localError = 'Enter your API token to continue.');
      return;
    }
    setState(() => _localError = null);

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.login(token);

    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.paper;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(c),
                  const Spacer(),
                  _buildForm(c),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(PaperColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaperCaption('Heroku, in your pocket', color: c.muted),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: PaperText.hero.copyWith(color: c.ink),
            children: [
              const TextSpan(text: 'Run your\napps from\n'),
              TextSpan(
                text: 'anywhere.',
                style: TextStyle(
                  color: c.accent,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(PaperColors c) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final error = _localError ?? authProvider.error;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tokenController,
                    obscureText: _obscureToken,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_localError != null) {
                        setState(() => _localError = null);
                      }
                      authProvider.clearError();
                    },
                    onSubmitted: (_) => _handleLogin(),
                    style: PaperText.body.copyWith(color: c.ink),
                    decoration: InputDecoration(
                      hintText: 'Heroku API token',
                      prefixIcon: Icon(Icons.vpn_key_rounded, size: 18),
                      prefixIconColor: c.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PaperIconButton(
                  icon: _obscureToken
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  tooltip: _obscureToken ? 'Show token' : 'Hide token',
                  onPressed: () =>
                      setState(() => _obscureToken = !_obscureToken),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline_rounded, size: 15, color: c.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error,
                      style: PaperText.bodySmall.copyWith(color: c.error),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            PaperButton(
              label: 'Connect account',
              variant: PaperButtonVariant.accent,
              expand: true,
              loading: authProvider.isLoading,
              onPressed: _handleLoadingGuard(authProvider),
            ),
            const SizedBox(height: 16),
            _buildTokenHelp(c),
          ],
        );
      },
    );
  }

  VoidCallback? _handleLoadingGuard(AuthProvider authProvider) {
    return authProvider.isLoading ? null : _handleLogin;
  }

  Widget _buildTokenHelp(PaperColors c) {
    return PaperCard(
      padding: const EdgeInsets.all(PaperTokens.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find your token', style: PaperText.h3.copyWith(color: c.ink)),
          const SizedBox(height: 6),
          Text(
            'Heroku Dashboard \u2192 Account settings \u2192 API Key \u2192 Reveal. '
            'Stored only in your device keychain.',
            style: PaperText.bodySmall.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}
