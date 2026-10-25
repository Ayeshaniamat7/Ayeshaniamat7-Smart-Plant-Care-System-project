import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/sensor_data_model.dart';
import '../models/ai_recommendation_model.dart';

class AIService extends ChangeNotifier {
  // Use 10.0.2.2 for Android Emulator, or localhost / local IP for physical dev device
  static const String baseUrl = "http://192.168.153.64:8000/api/v1";

  AIHealthResponse _healthDiagnosis = AIHealthResponse.initial();
  AIWateringResponse _wateringPrediction = AIWateringResponse.initial();
  bool _isAnalyzing = false;

  AIHealthResponse get healthDiagnosis => _healthDiagnosis;
  AIWateringResponse get wateringPrediction => _wateringPrediction;
  bool get isAnalyzing => _isAnalyzing;

  // Perform full ML inference using live telemetry
  Future<void> analyzeTelemetry(SensorDataModel sensorData) async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      final payload = jsonEncode({
        "soil_moisture": sensorData.soilMoisture.toDouble(),
        "temperature": sensorData.temperature,
        "humidity": sensorData.humidity,
        "light_level": sensorData.lightLevel.toDouble(),
      });

      // Call Health Endpoint
      final healthRes = await http
          .post(
            Uri.parse("$baseUrl/predict-health"),
            headers: {"Content-Type": "application/json"},
            body: payload,
          )
          .timeout(const Duration(seconds: 4));

      if (healthRes.statusCode == 200) {
        _healthDiagnosis = AIHealthResponse.fromJson(jsonDecode(healthRes.body));
      }

      // Call Watering Prediction Endpoint
      final waterRes = await http
          .post(
            Uri.parse("$baseUrl/predict-watering"),
            headers: {"Content-Type": "application/json"},
            body: payload,
          )
          .timeout(const Duration(seconds: 4));

      if (waterRes.statusCode == 200) {
        _wateringPrediction = AIWateringResponse.fromJson(jsonDecode(waterRes.body));
      }
    } catch (e) {
      debugPrint("AI Service connection fallback mode: $e");
      // Fallback rule evaluation if FastAPI offline
      _evaluateFallbackRules(sensorData);
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void _evaluateFallbackRules(SensorDataModel sensorData) {
    if (sensorData.soilMoisture < 25) {
      _healthDiagnosis = AIHealthResponse(
        healthStatus: "NEEDS_WATER",
        confidence: 95.0,
        recommendation: "Soil moisture critically low (${sensorData.soilMoisture}%). Water recommended.",
        alertLevel: "WARNING",
      );
      _wateringPrediction = AIWateringResponse(
        waterAmountMl: 250.0,
        recommendedPumpSeconds: 5,
        hoursUntilNextWater: 1.0,
        shouldWaterNow: true,
      );
    } else {
      _healthDiagnosis = AIHealthResponse(
        healthStatus: "HEALTHY_OPTIMAL",
        confidence: 98.0,
        recommendation: "Plant environment parameters are optimal.",
        alertLevel: "INFO",
      );
      _wateringPrediction = AIWateringResponse(
        waterAmountMl: 0.0,
        recommendedPumpSeconds: 0,
        hoursUntilNextWater: 24.0,
        shouldWaterNow: false,
      );
    }
  }
}
