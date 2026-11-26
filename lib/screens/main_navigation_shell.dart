import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import 'home_dashboard_screen.dart';
import 'my_devices_screen.dart';
import 'energy_consumption_screen.dart';
import 'historical_stats_screen.dart';
import 'user_profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    MyDevicesScreen(),
    EnergyConsumptionScreen(),
    HistoricalStatsScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.panelBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: loc.translate('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.electrical_services_rounded),
              label: loc.translate('devices'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bolt_rounded),
              label: loc.translate('consumption'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.analytics_rounded),
              label: loc.translate('analytics'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: loc.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
