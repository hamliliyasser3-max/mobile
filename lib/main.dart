import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/device_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Firebase configuration is loaded from google-services.json (Android) and
// GoogleService-Info.plist (iOS) placed in their standard platform directories.
// Never commit real credentials to source control.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait by default; landscape supported on tablets via config
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar: transparent with light icons to match dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Firebase (reads google-services.json / GoogleService-Info.plist)
  await Firebase.initializeApp();

  runApp(const EnergyNexApp());
}

class EnergyNexApp extends StatelessWidget {
  const EnergyNexApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (ctx, settings, _) {
          final isRtl = settings.currentLocale.languageCode == 'ar';

          return MaterialApp(
            title: 'ENERGY NEX',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            locale: settings.currentLocale,
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (ctx, child) {
              return Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SplashScreen(),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
