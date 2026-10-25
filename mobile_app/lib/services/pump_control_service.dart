import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PumpControlService extends ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  bool _isPumping = false;

  bool get isPumping => _isPumping;

  /// Sends the exact keys your ESP32 listens to:
  /// manualOverride: true and pumpSwitch: true
  Future<bool> triggerWaterPump({
    required String deviceId,
    int durationSeconds = 3,
  }) async {
    if (_isPumping) return false;

    _isPumping = true;
    notifyListeners();

    final DatabaseReference controlRef = _db.ref('devices/$deviceId/control');

    try {
      // 1. Activate pump on ESP32
      await controlRef.update({
        'manualOverride': true,
        'pumpSwitch': true,
        'triggered_at': ServerValue.timestamp,
      });

      // 2. Keep pump on for the duration
      await Future.delayed(Duration(seconds: durationSeconds));

      // 3. Turn off pump and return to AUTO mode on ESP32
      await controlRef.update({
        'manualOverride': false,
        'pumpSwitch': false,
        'reset_at': ServerValue.timestamp,
      });

      return true;
    } catch (e) {
      debugPrint("Firebase Pump Control Error: $e");
      rethrow;
    } finally {
      _isPumping = false;
      notifyListeners();
    }
  }
}