import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/paper_colors.dart';
import '../../../core/theme/paper_tokens.dart';
import '../../../data/models/app.dart';
import '../../providers/addon_provider.dart';
import '../../providers/config_provider.dart';
import '../../providers/dyno_provider.dart';
import '../../providers/release_provider.dart';
import '../../widgets/paper/paper_components.dart';
import 'tabs/addons_tab.dart';
import 'tabs/config_tab.dart';
import 'tabs/dynos_tab.dart';
import 'tabs/logs_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/releases_tab.dart';

class _Section {
  const _Section(this.label, this.icon);

  final String label;
  final IconData icon;
}

const List<_Section> _sections = [
  _Section('Overview', Icons.radio_button_unchecked),
  _Section('Dynos', Icons.dns_outlined),
  _Section('Config', Icons.key_outlined),
  _Section('Add-ons', Icons.extension_outlined),
  _Section('Logs', Icons.article_outlined),
  _Section('Releases', Icons.history),
];

class AppDetailsScreen extends StatefulWidget {
  final App app;

  const AppDetailsScreen({super.key, required this.app});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DynoProvider>().loadFormation(widget.app.id);
    });
  }

  void _refreshCurrent() {
    final appId = widget.app.id;
    switch (_index) {
      case 0:
        context.read<DynoProvider>().refreshFormation();
        context.read<ReleaseProvider>().refreshReleases(appId);
      case 1:
        context.read<DynoProvider>().refreshFormation();
      case 2:
        context.read<ConfigProvider>().loadConfigVars(appId, forceRefresh: true);
      case 3:
        context.read<AddonProvider>().loadAddons(appId);
      case 4:
        break;
      case 5:
        context.read<ReleaseProvider>().refreshReleases(appId);
    }
  }

  Widget _buildPane() {
    switch (_index) {
      case 0:
        return OverviewTab(app: widget.app);
      case 1:
        return DynosTab(app: widget.app);
      case 2:
        return ConfigTab(app: widget.app);
      case 3:
        return AddOnsTab(app: widget.app);
      case 4:
        return LogsTab(app: widget.app);
      default:
        return ReleasesTab(app: widget.app);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final subtitle = [
      widget.app.region,
      widget.app.stack,
    ].whereType<String>().join(' · ');

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              name: widget.app.name,
              subtitle: subtitle.isEmpty ? null : subtitle,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: _refreshCurrent,
            ),
            Expanded(child: _buildPane()),
          ],
        ),
      ),
      bottomNavigationBar: _PaperNav(
        sections: _sections,
        index: _index,
        onSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.name,
    required this.onBack,
    required this.onRefresh,
    this.subtitle,
  });

  final String name;
  final String? subtitle;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PaperTokens.s + 2,
        PaperTokens.s,
        PaperTokens.s + 2,
        PaperTokens.xs,
      ),
      child: Row(
        children: [
          PaperIconButton(
            icon: Icons.arrow_back,
            onPressed: onBack,
            tooltip: 'Back',
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  name,
                  style: PaperText.h3.copyWith(color: c.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      subtitle!,
                      style: PaperText.bodySmall.copyWith(color: c.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          PaperIconButton(
            icon: Icons.refresh,
            onPressed: onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }
}

class _PaperNav extends StatelessWidget {
  const _PaperNav({
    required this.sections,
    required this.index,
    required this.onSelected,
  });

  final List<_Section> sections;
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < sections.length; i++)
              Expanded(
                child: _NavButton(
                  section: sections[i],
                  selected: i == index,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final _Section section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final color = selected ? c.accent : c.muted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PaperTokens.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: selected ? c.accentSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(PaperTokens.rPill),
              ),
              child: Icon(section.icon, size: 18, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              section.label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
