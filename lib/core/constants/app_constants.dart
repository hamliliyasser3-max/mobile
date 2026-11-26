class AppConstants {
  // Firestore Collections
  static const String colUsers = 'users';
  static const String colDevices = 'devices';
  static const String colReadings = 'energy_readings';
  static const String colSettings = 'user_settings';

  // Device Types
  static const List<String> deviceTypes = [
    'Main Meter',
    'Sub-panel',
    'HVAC Unit',
    'Solar Inverter',
    'EV Charger',
    'Industrial Motor',
    'Lighting Circuit',
    'Server Rack'
  ];

  // Default Tariffs
  static const double defaultPricePerKwh = 0.18;
  static const double defaultDailyTargetKwh = 25.0;
  static const double defaultMonthlyBudgetCash = 150.0;
}
