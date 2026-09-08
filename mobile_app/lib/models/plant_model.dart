class PlantModel {
  final String plantId;
  final String userId;
  final String name;
  final String species;
  final String deviceId;
  final int minSoilMoisture;
  final int maxSoilMoisture;
  final double minTemperature;
  final double maxTemperature;
  final int minLightLevel;
  final int maxLightLevel;
  final String? imageUrl;
  final int createdAt;

  PlantModel({
    required this.plantId,
    required this.userId,
    required this.name,
    required this.species,
    required this.deviceId,
    required this.minSoilMoisture,
    required this.maxSoilMoisture,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minLightLevel,
    required this.maxLightLevel,
    this.imageUrl,
    required this.createdAt,
  });

  factory PlantModel.fromMap(Map<String, dynamic> map, String id) {
    return PlantModel(
      plantId: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Unnamed Plant',
      species: map['species'] ?? 'General Plant',
      deviceId: map['deviceId'] ?? 'plant_node_01',
      minSoilMoisture: (map['minSoilMoisture'] ?? 30).toInt(),
      maxSoilMoisture: (map['maxSoilMoisture'] ?? 80).toInt(),
      minTemperature: (map['minTemperature'] ?? 18.0).toDouble(),
      maxTemperature: (map['maxTemperature'] ?? 32.0).toDouble(),
      minLightLevel: (map['minLightLevel'] ?? 40).toInt(),
      maxLightLevel: (map['maxLightLevel'] ?? 90).toInt(),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'userId': userId,
      'name': name,
      'species': species,
      'deviceId': deviceId,
      'minSoilMoisture': minSoilMoisture,
      'maxSoilMoisture': maxSoilMoisture,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minLightLevel': minLightLevel,
      'maxLightLevel': maxLightLevel,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
