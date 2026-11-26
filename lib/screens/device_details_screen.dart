import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../models/device_model.dart';
import '../providers/device_provider.dart';

class DeviceDetailsScreen extends StatefulWidget {
  final DeviceModel device;
  const DeviceDetailsScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  late DeviceModel _currentDevice;

  @override
  void initState() {
    super.initState();
    _currentDevice = widget.device;
  }

  void _showEditDialog() {
    final loc = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: _currentDevice.deviceName);
    final locCtrl = TextEditingController(text: _currentDevice.location);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text(loc.translate('edit'),
            style: const TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppColors.text),
              decoration:
                  InputDecoration(labelText: loc.translate('deviceName')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locCtrl,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(labelText: loc.translate('location')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.translate('cancel'),
                style: const TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = _currentDevice.copyWith(
                deviceName: nameCtrl.text.trim(),
                location: locCtrl.text.trim(),
              );
              final success =
                  await Provider.of<DeviceProvider>(context, listen: false)
                      .updateDevice(updated);
              if (success && mounted) {
                setState(() => _currentDevice = updated);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.translate('deviceUpdated')),
                    backgroundColor: AppColors.green,
                  ),
                );
              }
            },
            child: Text(loc.translate('save')),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text(loc.translate('delete'),
            style: const TextStyle(color: AppColors.red)),
        content: Text(
          'Are you sure you want to permanently delete ${_currentDevice.deviceName}?',
          style: const TextStyle(color: AppColors.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.translate('cancel'),
                style: const TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () async {
              final success =
                  await Provider.of<DeviceProvider>(context, listen: false)
                      .deleteDevice(_currentDevice.deviceId);
              if (success && mounted) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.translate('deviceDeleted')),
                    backgroundColor: AppColors.amber,
                  ),
                );
              }
            },
            child: Text(loc.translate('delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isOnline = _currentDevice.status == 'online';
    final statusColor = isOnline ? AppColors.green : AppColors.cyan;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(_currentDevice.deviceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textDim),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon:
                const Icon(Icons.delete_outline_rounded, color: AppColors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Card
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
                          _currentDevice.deviceType,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _currentDevice.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentDevice.deviceName,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          _currentDevice.location,
                          style: const TextStyle(
                              color: AppColors.textDim, fontSize: 13),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.fingerprint,
                            size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'ID: ${_currentDevice.deviceId}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                                color: AppColors.muted, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Phase Telemetry Cards (2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: _MiniParamCard(
                    title: loc.translate('voltage'),
                    value: '231.2 V',
                    accentColor: AppColors.lime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniParamCard(
                    title: loc.translate('current'),
                    value: '6.45 A',
                    accentColor: AppColors.cyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniParamCard(
                    title: loc.translate('livePower'),
                    value: '1.49 kW',
                    accentColor: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniParamCard(
                    title: loc.translate('powerFactor'),
                    value: '0.98 cos φ',
                    accentColor: AppColors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Device 24h Load Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '24-Hour Load Profile',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 26,
                                getTitlesWidget: (v, m) => Text(
                                  v.toInt().toString(),
                                  style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.muted, fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 6,
                                getTitlesWidget: (v, m) => Text(
                                  '${v.toInt()}h',
                                  style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.muted, fontSize: 10),
                                ),
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
                          maxY: 3,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 0.4),
                                FlSpot(4, 0.3),
                                FlSpot(8, 1.2),
                                FlSpot(12, 1.8),
                                FlSpot(16, 1.6),
                                FlSpot(20, 2.2),
                                FlSpot(24, 0.7),
                              ],
                              isCurved: true,
                              color: AppColors.cyan,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.cyan.withValues(alpha: 0.12),
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
          ],
        ),
      ),
    );
  }
}

class _MiniParamCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accentColor;

  const _MiniParamCard({
    required this.title,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
