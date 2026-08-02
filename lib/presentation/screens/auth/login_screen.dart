import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:herokudroid/core/constants/theme_constants.dart';
import 'package:herokudroid/presentation/providers/auth_provider.dart';
import 'package:herokudroid/presentation/screens/dashboard/dashboard_screen.dart';

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
    final result = await authProvider.login(_tokenController.text.trim());

    if (mounted) {
      if (result['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Login failed'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo/icon - Modern gradient
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          ThemeConstants.primaryAccent,
                          ThemeConstants.secondaryAccent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConstants.primaryAccent.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cloud_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App name
                  const Text(
                    'HerokuDroid',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Manage your Heroku apps with ease',
                    style: TextStyle(
                      fontSize: 15,
                      color: ThemeConstants.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Token input field
                  TextFormField(
                    controller: _tokenController,
                    obscureText: _obscureToken,
                    onChanged: (_) {
                      context.read<AuthProvider>().clearError();
                    },
                    decoration: InputDecoration(
                      labelText: 'API Token',
                      hintText: 'Enter your Heroku API token',
                      prefixIcon: const Icon(Icons.vpn_key_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureToken
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          size: 20,
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
                  const SizedBox(height: 20),

                  // Error message
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.error != null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: ThemeConstants.statusError.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ThemeConstants.statusError.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: ThemeConstants.statusError,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: const TextStyle(
                                    fontSize: 13,
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
