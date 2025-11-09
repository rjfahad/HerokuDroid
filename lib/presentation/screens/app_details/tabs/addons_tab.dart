import 'package:flutter/material.dart';
import '../../../../data/models/app.dart';
import '../../../widgets/addons/addons_content.dart';

class AddOnsTab extends StatelessWidget {
  final App app;

  const AddOnsTab({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return AddonsContent(appId: app.id);
  }
}
