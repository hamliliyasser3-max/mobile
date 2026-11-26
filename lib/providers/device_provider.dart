import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/energy_reading.dart';
import '../services/firestore_service.dart';

class DeviceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<DeviceModel> _devices = [];
  List<EnergyReading> _readings = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<DeviceModel>>? _devicesSubscription;
  StreamSubscription<List<EnergyReading>>? _readingsSubscription;

  List<DeviceModel> get devices => _devices;
  List<EnergyReading> get readings => _readings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get onlineCount => _devices.where((d) => d.status == 'online').length;
  int get offlineCount => _devices.where((d) => d.status == 'offline').length;
  int get totalCount => _devices.length;

  void bindUser(String? uid) {
    _devicesSubscription?.cancel();
    _readingsSubscription?.cancel();

    if (uid == null) {
      _devices = [];
      _readings = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _devicesSubscription = _firestoreService.streamDevices(uid).listen(
      (deviceList) {
        _devices = deviceList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    _readingsSubscription = _firestoreService.streamReadings(uid).listen(
      (readingList) {
        _readings = readingList;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addDevice({
    required String ownerUid,
    required String deviceName,
    required String deviceType,
    required String location,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addDevice(
        ownerUid: ownerUid,
        deviceName: deviceName,
        deviceType: deviceType,
        location: location,
      );
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDevice(DeviceModel device) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateDevice(device);
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDevice(String deviceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteDevice(deviceId);
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _readingsSubscription?.cancel();
    super.dispose();
  }
}
