class SensorHistoryPoint {
  final DateTime timestamp;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double lightLevel;

  SensorHistoryPoint({
    required this.timestamp,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.lightLevel,
  });

  factory SensorHistoryPoint.fromMap(Map<String, dynamic> map, DateTime time) {
    return SensorHistoryPoint(
      timestamp: time,
      soilMoisture: (map['soilMoisture'] ?? 0).toDouble(),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      lightLevel: (map['lightLevel'] ?? 0).toDouble(),
    );
  }
}
