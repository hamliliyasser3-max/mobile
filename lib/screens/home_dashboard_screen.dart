import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../providers/device_provider.dart';
import '../providers/settings_provider.dart';
import 'add_device_screen.dart';
import 'settings_screen.dart';
import 'language_selection_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    // Calculate dynamic power & metrics
    final totalDevices = deviceProvider.totalCount;
    final onlineDevices = deviceProvider.onlineCount;
    final activeDevicesCount = totalDevices > 0
        ? (onlineDevices > 0 ? onlineDevices : totalDevices)
        : 3;

    // Base calibrated telemetry
    final double liveKw = 3.8 + (activeDevicesCount * 0.45);
    const double energyToday = 18.4;
    final double targetPercent =
        min(100.0, (energyToday / settings.dailyTargetKwh) * 100);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded,
                  color: AppColors.lime, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              loc.translate('brand'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded, color: AppColors.textDim),
            tooltip: loc.translate('language'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const LanguageSelectionScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textDim),
            tooltip: loc.translate('settings'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calibrated Demo Mode Notice Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loc.translate('demoNotice'),
                      style: const TextStyle(
                          color: AppColors.amber, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Top Status Bar: Live badge & quick timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE TELEMETRY',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Sampling: 2.5s',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4 KPI Metric Cards (2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: loc.translate('livePower'),
                    value: '${liveKw.toStringAsFixed(2)} kW',
                    subtitle: '230.4 V • 18.2 A',
                    accentColor: AppColors.lime,
                    icon: Icons.flash_on_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: loc.translate('energyToday'),
                    value: '${energyToday.toStringAsFixed(1)} kWh',
                    subtitle:
                        '${targetPercent.toStringAsFixed(0)}% of daily target',
                    accentColor: AppColors.cyan,
                    icon: Icons.battery_charging_full_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: loc.translate('gridFrequency'),
                    value: '50.02 Hz',
                    subtitle: 'PF: 0.97 (Lagging)',
                    accentColor: AppColors.green,
                    icon: Icons.speed_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: loc.translate('activeDevices'),
                    value:
                        '$activeDevicesCount Node${activeDevicesCount > 1 ? "s" : ""}',
                    subtitle: '$totalDevices registered total',
                    accentColor: AppColors.amber,
                    icon: Icons.sensors_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Real-Time Load Profile Chart Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.translate('loadCurve'),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.panelBorder),
                          ),
                          child: Text(
                            'Today (kW)',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.lime,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 190,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1.5,
                            getDrawingHorizontalLine: (value) => const FlLine(
                              color: AppColors.panelBorder,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1.5,
                                getTitlesWidget: (val, meta) => Text(
                                  val.toInt().toString(),
                                  style: GoogleFonts.jetBrainsMono(
                                    color: AppColors.muted,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 4,
                                getTitlesWidget: (val, meta) {
                                  final hours = [
                                    '00:00',
                                    '04:00',
                                    '08:00',
                                    '12:00',
                                    '16:00',
                                    '20:00',
                                    '24:00'
                                  ];
                                  final idx = (val / 4).clamp(0, 6).toInt();
                                  return Text(
                                    hours[idx],
                                    style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.muted,
                                      fontSize: 9,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 24,
                          minY: 0,
                          maxY: 6,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1.8),
                                FlSpot(3, 1.4),
                                FlSpot(6, 2.3),
                                FlSpot(9, 4.2),
                                FlSpot(12, 3.8),
                                FlSpot(15, 4.6),
                                FlSpot(18, 5.4),
                                FlSpot(21, 3.9),
                                FlSpot(24, 2.1),
                              ],
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: AppColors.lime,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.lime.withValues(alpha: 0.25),
                                    AppColors.lime.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Devices Section Header & Add Device Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('devices'),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AddDeviceScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16, color: AppColors.lime),
                  label: Text(
                    loc.translate('addDevice'),
                    style: const TextStyle(
                        color: AppColors.lime,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Quick Device List Preview
            if (deviceProvider.devices.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 16.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.electrical_services_rounded,
                            color: AppColors.muted, size: 36),
                        const SizedBox(height: 10),
                        Text(
                          loc.translate('noDevices'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textDim, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...deviceProvider.devices
                  .take(3)
                  .map((dev) => _DeviceListTile(device: dev)),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accentColor;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                Icon(icon, size: 16, color: accentColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textDim, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceListTile extends StatelessWidget {
  final dynamic device;
  const _DeviceListTile({required this.device});

  @override
  Widget build(BuildContext context) {
    final isOnline = device.status == 'online';
    final statusColor = isOnline
        ? AppColors.green
        : (device.status == 'awaiting_data' ? AppColors.cyan : AppColors.amber);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.panelBorder),
          ),
          child: const Icon(Icons.flash_on_rounded,
              color: AppColors.lime, size: 20),
        ),
        title: Text(
          device.deviceName,
          style: const TextStyle(
              color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          '${device.deviceType} • ${device.location}',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            device.status.toString().toUpperCase(),
            style: TextStyle(
                color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
