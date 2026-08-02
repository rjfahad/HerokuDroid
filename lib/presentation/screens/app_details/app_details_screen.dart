import 'package:flutter/material.dart';
import 'package:herokudroid/core/constants/theme_constants.dart';
import 'package:provider/provider.dart';
import '../../../data/models/app.dart';
import '../../providers/dyno_provider.dart';
import 'tabs/overview_tab.dart';
import 'tabs/dynos_tab.dart';
import 'tabs/config_tab.dart';
import 'tabs/addons_tab.dart';
import 'tabs/logs_tab.dart';
import 'tabs/releases_tab.dart';

class AppDetailsScreen extends StatefulWidget {
  final App app;

  const AppDetailsScreen({super.key, required this.app});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load dyno formation to check status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DynoProvider>().loadFormation(widget.app.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(child: Text(widget.app.name)),
              Consumer<DynoProvider>(
                builder: (context, dynoProvider, child) {
                  // Calculate status based on dyno quantity
                  bool hasRunningDynos = false;
                  if (dynoProvider.formations.isNotEmpty) {
                    hasRunningDynos = dynoProvider.formations.any(
                      (formation) => formation.quantity > 0,
                    );
                  }

                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: hasRunningDynos ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: ThemeConstants.primaryAccent,
            unselectedLabelColor: ThemeConstants.textSecondary,
            indicatorColor: ThemeConstants.primaryAccent,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Dynos'),
              Tab(text: 'Config'),
              Tab(text: 'Add-ons'),
              Tab(text: 'Logs'),
              Tab(text: 'Releases'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OverviewTab(app: widget.app),
            DynosTab(app: widget.app),
            ConfigTab(app: widget.app),
            AddOnsTab(app: widget.app),
            LogsTab(app: widget.app),
            ReleasesTab(app: widget.app),
          ],
        ),
      ),
    );
  }
}
