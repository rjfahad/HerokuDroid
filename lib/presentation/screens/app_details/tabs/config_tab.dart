import 'package:flutter/material.dart';
import '../../../../data/models/app.dart';
import '../../../widgets/config_vars/config_vars_content.dart';

class ConfigTab extends StatelessWidget {
  final App app;

  const ConfigTab({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return ConfigVarsContent(appId: app.id, showFab: true);
  }
}
