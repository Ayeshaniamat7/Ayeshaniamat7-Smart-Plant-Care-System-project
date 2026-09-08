import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/sensor_data_model.dart';

class SensorService extends ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  StreamSubscription<DatabaseEvent>? _sensorSubscription;

  SensorDataModel _currentReadings = SensorDataModel.initial();
  bool _isConnected = false;

  SensorDataModel get currentReadings => _currentReadings;
  bool get isConnected => _isConnected;

  // Listen to real-time updates for a specific hardware device ID
  void listenToDevice(String deviceId) {
    _sensorSubscription?.cancel();

    DatabaseReference ref = _db.ref('devices/$deviceId/live');

    _sensorSubscription = ref.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        _currentReadings = SensorDataModel.fromMap(data);
        _isConnected = true;
      } else {
        _currentReadings = SensorDataModel.initial();
        _isConnected = false;
      }
      notifyListeners();
    }, onError: (error) {
      _isConnected = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
