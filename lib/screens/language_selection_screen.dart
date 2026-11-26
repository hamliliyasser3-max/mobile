import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = Provider.of<SettingsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final languages = [
      {
        'code': 'en',
        'name': 'English',
        'nativeName': 'English',
        'region': 'Universal',
        'icon': '🇬🇧',
        'dir': 'LTR',
      },
      {
        'code': 'fr',
        'name': 'French',
        'nativeName': 'Français',
        'region': 'France / Maghreb',
        'icon': '🇫🇷',
        'dir': 'LTR',
      },
      {
        'code': 'ar',
        'name': 'Arabic',
        'nativeName': 'العربية',
        'region': 'المنطقة العربية',
        'icon': '🇩🇿',
        'dir': 'RTL',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(loc.translate('language')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.panelBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.cyan, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Arabic enables Right-to-Left layout automatically across the entire application.',
                      style: TextStyle(
                          color: AppColors.textDim, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: languages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final lang = languages[i];
                  final isSelected =
                      settings.currentLocale.languageCode == lang['code'];

                  return GestureDetector(
                    onTap: () async {
                      await settings.setLocale(
                        lang['code']!,
                        uid: auth.currentUser?.uid,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.lime.withValues(alpha: 0.1)
                            : AppColors.panel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.lime
                              : AppColors.panelBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(lang['icon']!,
                              style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['nativeName']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.lime
                                        : AppColors.text,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      lang['name']!,
                                      style: const TextStyle(
                                          color: AppColors.textDim,
                                          fontSize: 12),
                                    ),
                                    const Text(
                                      ' • ',
                                      style: TextStyle(
                                          color: AppColors.muted, fontSize: 12),
                                    ),
                                    Text(
                                      lang['region']!,
                                      style: const TextStyle(
                                          color: AppColors.muted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: lang['dir'] == 'RTL'
                                      ? AppColors.amber.withValues(alpha: 0.15)
                                      : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: lang['dir'] == 'RTL'
                                        ? AppColors.amber.withValues(alpha: 0.3)
                                        : AppColors.panelBorder,
                                  ),
                                ),
                                child: Text(
                                  lang['dir']!,
                                  style: TextStyle(
                                    color: lang['dir'] == 'RTL'
                                        ? AppColors.amber
                                        : AppColors.muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.lime, size: 20)
                              else
                                const Icon(Icons.radio_button_unchecked_rounded,
                                    color: AppColors.panelBorder, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
