import 'package:flutter/material.dart';
import '../../../../data/models/app.dart';
import '../../logs/logs_screen.dart';

class LogsTab extends StatelessWidget {
  final App app;

  const LogsTab({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    // Embed LogsScreen without AppBar (parent TabBar provides navigation)
    return LogsScreen(
      appId: app.id,
      appName: app.name,
      showAppBar: false, // No app bar when embedded in tab
    );
  }
}
