import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String deviceId;
  final String ownerUid;
  final String deviceName;
  final String deviceType;
  final String location;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.deviceId,
    required this.ownerUid,
    required this.deviceName,
    required this.deviceType,
    required this.location,
    this.status = 'awaiting_data',
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceModel.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return DeviceModel(
      deviceId: id,
      ownerUid: data['ownerUid'] ?? '',
      deviceName: data['deviceName'] ?? 'Unnamed Meter',
      deviceType: data['deviceType'] ?? 'Main Meter',
      location: data['location'] ?? 'Main Panel',
      status: data['status'] ?? 'awaiting_data',
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'deviceId': deviceId,
      'ownerUid': ownerUid,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'location': location,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DeviceModel copyWith({
    String? deviceName,
    String? deviceType,
    String? location,
    String? status,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      deviceId: deviceId,
      ownerUid: ownerUid,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
