import 'package:flutter/material.dart';
import '../../../data/models/app.dart';
import 'tabs/overview_tab.dart';
import 'tabs/dynos_tab.dart';
import 'tabs/config_tab.dart';
import 'tabs/addons_tab.dart';
import 'tabs/logs_tab.dart';

class AppDetailsScreen extends StatelessWidget {
  final App app;

  const AppDetailsScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(app.name),
          bottom: TabBar(
            isScrollable: false,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Dynos'),
              Tab(text: 'Config'),
              Tab(text: 'Add-ons'),
              Tab(text: 'Logs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OverviewTab(app: app),
            DynosTab(app: app),
            ConfigTab(app: app),
            AddOnsTab(app: app),
            LogsTab(app: app),
          ],
        ),
      ),
    );
  }
}
