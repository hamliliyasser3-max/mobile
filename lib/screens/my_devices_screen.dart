import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../providers/device_provider.dart';
import 'add_device_screen.dart';
import 'device_details_screen.dart';

class MyDevicesScreen extends StatefulWidget {
  const MyDevicesScreen({Key? key}) : super(key: key);

  @override
  State<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends State<MyDevicesScreen> {
  String _filter = 'all'; // 'all', 'online', 'awaiting_data'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);

    var devices = deviceProvider.devices;
    if (_filter != 'all') {
      devices = devices.where((d) => d.status == _filter).toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      devices = devices
          .where((d) =>
              d.deviceName.toLowerCase().contains(query) ||
              d.location.toLowerCase().contains(query) ||
              d.deviceType.toLowerCase().contains(query))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(loc.translate('devices')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.lime),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by meter name or zone...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.muted, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.muted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                _filterChip('all', 'All (${deviceProvider.devices.length})'),
                const SizedBox(width: 8),
                _filterChip('online', 'Online (${deviceProvider.onlineCount})'),
                const SizedBox(width: 8),
                _filterChip('awaiting_data',
                    'Awaiting (${deviceProvider.devices.length - deviceProvider.onlineCount})'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: deviceProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.lime),
                  )
                : devices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.bg2,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.panelBorder),
                              ),
                              child: const Icon(
                                Icons.electrical_services_rounded,
                                size: 48,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc.translate('noDevices'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textDim, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const AddDeviceScreen()),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: Text(loc.translate('addDevice')),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        itemCount: devices.length,
                        itemBuilder: (ctx, i) {
                          final dev = devices[i];
                          final isOnline = dev.status == 'online';
                          final statusColor = isOnline
                              ? AppColors.green
                              : (dev.status == 'awaiting_data'
                                  ? AppColors.cyan
                                  : AppColors.amber);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: AppColors.panelBorder),
                                ),
                                child: const Icon(Icons.developer_board_rounded,
                                    color: AppColors.lime, size: 22),
                              ),
                              title: Text(
                                dev.deviceName,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${dev.deviceType} • ${dev.location}',
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 13),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: statusColor.withValues(
                                              alpha: 0.3)),
                                    ),
                                    child: Text(
                                      dev.status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: AppColors.muted),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DeviceDetailsScreen(device: dev),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.bg,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lime.withValues(alpha: 0.15)
              : AppColors.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.lime : AppColors.panelBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.lime : AppColors.muted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
