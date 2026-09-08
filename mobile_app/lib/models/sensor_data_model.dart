class SensorDataModel {
  final double temperature;
  final double humidity;
  final int soilMoisture;
  final int lightLevel;
  final int timestamp;
  final String status;

  SensorDataModel({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.lightLevel,
    required this.timestamp,
    required this.status,
  });

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    return SensorDataModel(
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      soilMoisture: (map['soilMoisture'] ?? 0).toInt(),
      lightLevel: (map['lightLevel'] ?? 0).toInt(),
      timestamp: (map['timestamp'] ?? 0).toInt(),
      status: map['status'] ?? 'offline',
    );
  }

  factory SensorDataModel.initial() {
    return SensorDataModel(
      temperature: 0.0,
      humidity: 0.0,
      soilMoisture: 0,
      lightLevel: 0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: 'connecting',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soilMoisture': soilMoisture,
      'lightLevel': lightLevel,
      'timestamp': timestamp,
      'status': status,
    };
  }
}
