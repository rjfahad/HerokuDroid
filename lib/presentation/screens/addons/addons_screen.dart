import 'package:flutter/material.dart';
import 'package:herokudroid/presentation/widgets/addons/addons_content.dart';

/// Screen for viewing add-ons
class AddonsScreen extends StatelessWidget {
  final String appId;
  final String appName;

  const AddonsScreen({required this.appId, required this.appName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$appName\nAdd-ons')),
      body: AddonsContent(appId: appId),
    );
  }
}
