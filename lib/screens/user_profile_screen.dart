import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'language_selection_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final devProvider = Provider.of<DeviceProvider>(context);
    final user = auth.currentUser;

    final name = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Energy Administrator';
    final email =
        user?.email.isNotEmpty == true ? user!.email : 'admin@energynex.io';
    final uid = user?.uid ?? 'ENX-8942-AUTH';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(loc.translate('profile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // User Avatar & Identity Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lime, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lime.withValues(alpha: 0.2),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'E',
                          style: const TextStyle(
                            color: AppColors.lime,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                          color: AppColors.textDim, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.panelBorder),
                      ),
                      child: Text(
                        'UID: ${uid.length > 16 ? '${uid.substring(0, 16)}...' : uid}',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${devProvider.totalCount}',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.lime,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Nodes Registered',
                            style:
                                TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Active',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.cyan,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Account Status',
                            style:
                                TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account Action List
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined,
                        color: AppColors.lime),
                    title: Text(loc.translate('settings'),
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(color: AppColors.panelBorder, height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_rounded,
                        color: AppColors.cyan),
                    title: Text(loc.translate('language'),
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 14)),
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
                  const ListTile(
                    leading:
                        Icon(Icons.security_rounded, color: AppColors.green),
                    title: Text('Security & Rules',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    subtitle: Text('Protected by Firestore Security Rules',
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    trailing: Icon(Icons.verified_user_rounded,
                        color: AppColors.green, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                ),
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(loc.translate('logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
