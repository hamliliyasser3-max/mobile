import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettingsModel {
  final String ownerUid;
  final String language;
  final bool notificationsEnabled;
  final String theme;
  final double electricityPrice;
  final double dailyTarget;
  final double monthlyBudget;
  final DateTime updatedAt;

  UserSettingsModel({
    required this.ownerUid,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.theme = 'dark',
    this.electricityPrice = 0.18,
    this.dailyTarget = 25.0,
    this.monthlyBudget = 150.0,
    required this.updatedAt,
  });

  factory UserSettingsModel.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return UserSettingsModel(
      ownerUid: id,
      language: data['language'] ?? 'en',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      theme: data['theme'] ?? 'dark',
      electricityPrice: (data['electricityPrice'] as num?)?.toDouble() ?? 0.18,
      dailyTarget: (data['dailyTarget'] as num?)?.toDouble() ?? 25.0,
      monthlyBudget: (data['monthlyBudget'] as num?)?.toDouble() ?? 150.0,
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerUid': ownerUid,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'theme': theme,
      'electricityPrice': electricityPrice,
      'dailyTarget': dailyTarget,
      'monthlyBudget': monthlyBudget,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserSettingsModel copyWith({
    String? language,
    bool? notificationsEnabled,
    String? theme,
    double? electricityPrice,
    double? dailyTarget,
    double? monthlyBudget,
  }) {
    return UserSettingsModel(
      ownerUid: ownerUid,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      theme: theme ?? this.theme,
      electricityPrice: electricityPrice ?? this.electricityPrice,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      updatedAt: DateTime.now(),
    );
  }
}
