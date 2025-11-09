import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokuandroid/core/constants/theme_constants.dart';
import 'package:herokuandroid/presentation/providers/auth_provider.dart';
import 'package:herokuandroid/presentation/screens/dashboard/dashboard_screen.dart';

/// Login screen for API token input
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _obscureToken = true;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(_tokenController.text.trim());

    if (success && mounted) {
      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeConstants.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo/icon
                  Icon(
                    Icons.cloud,
                    size: ThemeConstants.iconSizeXl * 2,
                    color: ThemeConstants.herokuPurple,
                  ),
                  const SizedBox(height: ThemeConstants.spacingL),

                  // App name
                  Text(
                    'HerokuDroid',
                    style: ThemeConstants.headingLarge.copyWith(
                      color: ThemeConstants.herokuPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ThemeConstants.spacingS),

                  // Subtitle
                  Text(
                    'Manage your Heroku apps on the go',
                    style: ThemeConstants.bodyMedium.copyWith(
                      color: ThemeConstants.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ThemeConstants.spacingXl),

                  // Token input field
                  TextFormField(
                    controller: _tokenController,
                    obscureText: _obscureToken,
                    decoration: InputDecoration(
                      labelText: 'API Token',
                      hintText: 'Enter your Heroku API token',
                      prefixIcon: const Icon(Icons.vpn_key),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureToken
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureToken = !_obscureToken;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your API token';
                      }
                      if (value.trim().length < 10) {
                        return 'Token seems too short';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: ThemeConstants.spacingL),

                  // Error message
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.error != null) {
                        return Container(
                          padding: const EdgeInsets.all(
                            ThemeConstants.spacingM,
                          ),
                          margin: const EdgeInsets.only(
                            bottom: ThemeConstants.spacingL,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConstants.statusError.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              ThemeConstants.radiusM,
                            ),
                            border: Border.all(
                              color: ThemeConstants.statusError,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: ThemeConstants.statusError,
                              ),
                              const SizedBox(width: ThemeConstants.spacingM),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: ThemeConstants.bodySmall.copyWith(
                                    color: ThemeConstants.statusError,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Login button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Login'),
                      );
                    },
                  ),
                  const SizedBox(height: ThemeConstants.spacingXl),

                  // Instructions
                  _buildInstructions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: ThemeConstants.statusInfo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        border: Border.all(color: ThemeConstants.statusInfo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ThemeConstants.statusInfo,
                size: ThemeConstants.iconSizeM,
              ),
              const SizedBox(width: ThemeConstants.spacingS),
              Text(
                'How to get your API token',
                style: ThemeConstants.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.statusInfo,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingS),
          Text(
            '1. Install Heroku CLI\n'
            '2. Run: heroku auth:token\n'
            '3. Copy the token and paste it above',
            style: ThemeConstants.bodySmall.copyWith(
              color: ThemeConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
