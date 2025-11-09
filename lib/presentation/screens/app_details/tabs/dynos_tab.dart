import 'package:flutter/material.dart';
import '../../../../data/models/app.dart';
import '../../../widgets/dynos/dynos_content.dart';

class DynosTab extends StatelessWidget {
  final App app;

  const DynosTab({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return DynosContent(appId: app.id);
  }
}
