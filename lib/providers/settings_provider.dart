import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings_model.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Locale _currentLocale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.dark;
  double _pricePerKwh = AppConstants.defaultPricePerKwh;
  double _dailyTargetKwh = AppConstants.defaultDailyTargetKwh;
  double _monthlyBudgetCash = AppConstants.defaultMonthlyBudgetCash;
  bool _notificationsEnabled = true;

  Locale get currentLocale => _currentLocale;
  ThemeMode get themeMode => _themeMode;
  double get pricePerKwh => _pricePerKwh;
  double get dailyTargetKwh => _dailyTargetKwh;
  double get monthlyBudgetCash => _monthlyBudgetCash;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('pref_lang') ?? 'en';
    final isDark = prefs.getBool('pref_dark') ?? true;
    _pricePerKwh = prefs.getDouble('pref_price') ?? AppConstants.defaultPricePerKwh;
    _dailyTargetKwh = prefs.getDouble('pref_target') ?? AppConstants.defaultDailyTargetKwh;
    _monthlyBudgetCash = prefs.getDouble('pref_budget') ?? AppConstants.defaultMonthlyBudgetCash;
    _notificationsEnabled = prefs.getBool('pref_notif') ?? true;

    _currentLocale = Locale(lang);
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setLocale(String langCode, {String? uid}) async {
    _currentLocale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_lang', langCode);
    notifyListeners();

    if (uid != null) {
      _syncToFirestore(uid);
    }
  }

  Future<void> setThemeMode(ThemeMode mode, {String? uid}) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_dark', mode == ThemeMode.dark);
    notifyListeners();

    if (uid != null) {
      _syncToFirestore(uid);
    }
  }

  Future<void> updateTariffs({
    required double price,
    required double target,
    required double budget,
    String? uid,
  }) async {
    _pricePerKwh = price;
    _dailyTargetKwh = target;
    _monthlyBudgetCash = budget;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pref_price', price);
    await prefs.setDouble('pref_target', target);
    await prefs.setDouble('pref_budget', budget);
    notifyListeners();

    if (uid != null) {
      _syncToFirestore(uid);
    }
  }

  void _syncToFirestore(String uid) {
    final settings = UserSettingsModel(
      ownerUid: uid,
      language: _currentLocale.languageCode,
      notificationsEnabled: _notificationsEnabled,
      theme: _themeMode == ThemeMode.dark ? 'dark' : 'light',
      electricityPrice: _pricePerKwh,
      dailyTarget: _dailyTargetKwh,
      monthlyBudget: _monthlyBudgetCash,
      updatedAt: DateTime.now(),
    );
    _firestoreService.updateSettings(settings);
  }
}
