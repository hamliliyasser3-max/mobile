import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _priceCtrl;
  late TextEditingController _targetCtrl;
  late TextEditingController _budgetCtrl;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _priceCtrl =
        TextEditingController(text: settings.pricePerKwh.toStringAsFixed(2));
    _targetCtrl =
        TextEditingController(text: settings.dailyTargetKwh.toStringAsFixed(0));
    _budgetCtrl = TextEditingController(
        text: settings.monthlyBudgetCash.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _targetCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTariffs() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final price = double.tryParse(_priceCtrl.text) ?? settings.pricePerKwh;
    final target = double.tryParse(_targetCtrl.text) ?? settings.dailyTargetKwh;
    final budget =
        double.tryParse(_budgetCtrl.text) ?? settings.monthlyBudgetCash;

    await settings.updateTariffs(
      price: price,
      target: target,
      budget: budget,
      uid: auth.currentUser?.uid,
    );

    if (mounted) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.translate('settings')} saved successfully'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(loc.translate('settings')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tariffs & Energy Targets
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tariffs & Energy Targets',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText:
                            '${loc.translate('electricityPrice')} (\$/kWh)',
                        prefixIcon: const Icon(Icons.attach_money_rounded,
                            color: AppColors.lime),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _targetCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: '${loc.translate('dailyTarget')} (kWh)',
                        prefixIcon: const Icon(Icons.track_changes_rounded,
                            color: AppColors.cyan),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _budgetCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: '${loc.translate('monthlyBudget')} (\$)',
                        prefixIcon: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.amber),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTariffs,
                        child: Text(loc.translate('save')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Preferences Card
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded,
                        color: AppColors.cyan),
                    title: Text(loc.translate('language'),
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 14)),
                    subtitle: Text(
                      settings.currentLocale.languageCode == 'ar'
                          ? 'العربية (RTL)'
                          : settings.currentLocale.languageCode == 'fr'
                              ? 'Français'
                              : 'English',
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const LanguageSelectionScreen()),
                      );
                    },
                  ),
                  const Divider(color: AppColors.panelBorder, height: 1),
                  SwitchListTile(
                    activeThumbColor: AppColors.lime,
                    secondary: const Icon(Icons.notifications_active_outlined,
                        color: AppColors.lime),
                    title: Text(loc.translate('notifications'),
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 14)),
                    value: settings.notificationsEnabled,
                    onChanged: (val) {
                      // Toggle notifications
                    },
                  ),
                  const Divider(color: AppColors.panelBorder, height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined,
                        color: AppColors.amber),
                    title: Text(loc.translate('theme'),
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 14)),
                    subtitle: const Text('Energy Nex Neon Dark (Default)',
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('DARK',
                          style: TextStyle(
                              color: AppColors.lime,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
