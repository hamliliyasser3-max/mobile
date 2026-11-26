import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({Key? key}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedType = AppConstants.deviceTypes.first;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final devProvider = Provider.of<DeviceProvider>(context, listen: false);

    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    final success = await devProvider.addDevice(
      ownerUid: uid,
      deviceName: _nameController.text,
      deviceType: _selectedType,
      location: _locationController.text,
    );

    if (!mounted) return;

    if (success) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('deviceAdded')),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(devProvider.errorMessage ?? 'Failed to register device'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final devProvider = Provider.of<DeviceProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(loc.translate('addDevice')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('deviceName'),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.text),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Primary Incomer, HVAC Rooftop 1',
                            prefixIcon: Icon(Icons.badge_outlined,
                                color: AppColors.muted),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return loc.translate('errorRequired');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          loc.translate('deviceType'),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          dropdownColor: AppColors.panel,
                          style: const TextStyle(color: AppColors.text),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.category_outlined,
                                color: AppColors.muted),
                          ),
                          items: AppConstants.deviceTypes.map((t) {
                            return DropdownMenuItem(value: t, child: Text(t));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedType = val);
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          loc.translate('location'),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locationController,
                          style: const TextStyle(color: AppColors.text),
                          decoration: const InputDecoration(
                            hintText:
                                'e.g. Substation B, Floor 3 Electrical Room',
                            prefixIcon: Icon(Icons.place_outlined,
                                color: AppColors.muted),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return loc.translate('errorRequired');
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.panelBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.cyan, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Once added, telemetry ingestion will initialize automatically with calibrated demonstration data until physical IoT hardware connects.',
                          style: TextStyle(
                              color: AppColors.textDim,
                              fontSize: 12,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: devProvider.isLoading ? null : _handleSubmit,
                    child: devProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.bg),
                          )
                        : Text(loc.translate('save')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
