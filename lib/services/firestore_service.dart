import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_model.dart';
import '../models/energy_reading.dart';
import '../models/user_settings_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time devices stream scoped to the authenticated user
  Stream<List<DeviceModel>> streamDevices(String uid) {
    return _db
        .collection(AppConstants.colDevices)
        .where('ownerUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DeviceModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Create a new device
  Future<void> addDevice({
    required String ownerUid,
    required String deviceName,
    required String deviceType,
    required String location,
  }) async {
    final docRef = _db.collection(AppConstants.colDevices).doc();
    final newDevice = DeviceModel(
      deviceId: docRef.id,
      ownerUid: ownerUid,
      deviceName: deviceName.trim(),
      deviceType: deviceType,
      location: location.trim(),
      status: 'awaiting_data',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(newDevice.toFirestore());
  }

  // Update existing device
  Future<void> updateDevice(DeviceModel device) async {
    await _db
        .collection(AppConstants.colDevices)
        .doc(device.deviceId)
        .update(device.copyWith(updatedAt: DateTime.now()).toFirestore());
  }

  // Delete device
  Future<void> deleteDevice(String deviceId) async {
    await _db.collection(AppConstants.colDevices).doc(deviceId).delete();
  }

  // Real-time energy readings stream for the current user
  Stream<List<EnergyReading>> streamReadings(String uid, {int limit = 50}) {
    return _db
        .collection(AppConstants.colReadings)
        .where('ownerUid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EnergyReading.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a reading (from calibration simulation or hardware payload)
  Future<void> addReading(EnergyReading reading) async {
    final docRef = _db.collection(AppConstants.colReadings).doc();
    await docRef.set(reading.toFirestore());
  }

  // User Settings stream
  Stream<UserSettingsModel?> streamSettings(String uid) {
    return _db
        .collection(AppConstants.colSettings)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserSettingsModel.fromFirestore(snapshot.data()!, uid);
      }
      return null;
    });
  }

  // Update User Settings
  Future<void> updateSettings(UserSettingsModel settings) async {
    await _db
        .collection(AppConstants.colSettings)
        .doc(settings.ownerUid)
        .set(settings.toFirestore(), SetOptions(merge: true));
  }
}
