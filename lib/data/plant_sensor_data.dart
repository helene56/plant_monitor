// plant sensor class
// holds info about the actual sensor values

class PlantSensorData {
  final int id; // should be initialized with id from Plant
  final int water;
  final int sunLux;
  final int airTemp;
  final int earthTemp;
  final int humidity;

  const PlantSensorData({
    required this.id,
    required this.water,
    required this.sunLux,
    required this.airTemp,
    required this.earthTemp,
    required this.humidity
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'water': water,
      'sunLux': sunLux,
      'airTemp': airTemp,
      'earthTemp': earthTemp,
      'humidity': humidity,
    };
  }
}