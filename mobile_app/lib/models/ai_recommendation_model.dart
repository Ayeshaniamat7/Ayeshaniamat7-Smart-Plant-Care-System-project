class AIHealthResponse {
  final String healthStatus;
  final double confidence;
  final String recommendation;
  final String alertLevel; // INFO, WARNING, CRITICAL

  AIHealthResponse({
    required this.healthStatus,
    required this.confidence,
    required this.recommendation,
    required this.alertLevel,
  });

  factory AIHealthResponse.fromJson(Map<String, dynamic> json) {
    return AIHealthResponse(
      healthStatus: json['health_status'] ?? 'HEALTHY_OPTIMAL',
      confidence: (json['confidence'] ?? 100.0).toDouble(),
      recommendation: json['recommendation'] ?? 'Conditions stable.',
      alertLevel: json['alert_level'] ?? 'INFO',
    );
  }

  factory AIHealthResponse.initial() {
    return AIHealthResponse(
      healthStatus: 'HEALTHY_OPTIMAL',
      confidence: 99.0,
      recommendation: 'Analyzing plant telemetry with Scikit-learn AI...',
      alertLevel: 'INFO',
    );
  }
}

class AIWateringResponse {
  final double waterAmountMl;
  final int recommendedPumpSeconds;
  final double hoursUntilNextWater;
  final bool shouldWaterNow;

  AIWateringResponse({
    required this.waterAmountMl,
    required this.recommendedPumpSeconds,
    required this.hoursUntilNextWater,
    required this.shouldWaterNow,
  });

  factory AIWateringResponse.fromJson(Map<String, dynamic> json) {
    return AIWateringResponse(
      waterAmountMl: (json['water_amount_ml'] ?? 0.0).toDouble(),
      recommendedPumpSeconds: (json['recommended_pump_seconds'] ?? 0).toInt(),
      hoursUntilNextWater: (json['hours_until_next_water'] ?? 24.0).toDouble(),
      shouldWaterNow: json['should_water_now'] ?? false,
    );
  }

  factory AIWateringResponse.initial() {
    return AIWateringResponse(
      waterAmountMl: 0.0,
      recommendedPumpSeconds: 0,
      hoursUntilNextWater: 24.0,
      shouldWaterNow: false,
    );
  }
}
