import 'package:flutter/material.dart';
import 'package:herokuandroid/presentation/widgets/config_vars/config_vars_content.dart';

/// Screen for managing config vars (environment variables)
class ConfigVarsScreen extends StatelessWidget {
  final String appId;
  final String appName;

  const ConfigVarsScreen({
    required this.appId,
    required this.appName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$appName\nConfig Vars')),
      body: ConfigVarsContent(appId: appId),
    );
  }
}
