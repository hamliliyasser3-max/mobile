import 'package:cloud_firestore/cloud_firestore.dart';

class EnergyReading {
  final String readingId;
  final String ownerUid;
  final String deviceId;
  final double voltage;
  final double current;
  final double power;
  final double energyKwh;
  final DateTime timestamp;
  final String dataSource;

  EnergyReading({
    required this.readingId,
    required this.ownerUid,
    required this.deviceId,
    required this.voltage,
    required this.current,
    required this.power,
    required this.energyKwh,
    required this.timestamp,
    this.dataSource = 'calibrated_simulation',
  });

  factory EnergyReading.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return EnergyReading(
      readingId: id,
      ownerUid: data['ownerUid'] ?? '',
      deviceId: data['deviceId'] ?? '',
      voltage: (data['voltage'] as num?)?.toDouble() ?? 230.0,
      current: (data['current'] as num?)?.toDouble() ?? 0.0,
      power: (data['power'] as num?)?.toDouble() ?? 0.0,
      energyKwh: (data['energyKwh'] as num?)?.toDouble() ?? 0.0,
      timestamp: parseDate(data['timestamp']),
      dataSource: data['dataSource'] ?? 'calibrated_simulation',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'readingId': readingId,
      'ownerUid': ownerUid,
      'deviceId': deviceId,
      'voltage': voltage,
      'current': current,
      'power': power,
      'energyKwh': energyKwh,
      'timestamp': Timestamp.fromDate(timestamp),
      'dataSource': dataSource,
    };
  }
}
