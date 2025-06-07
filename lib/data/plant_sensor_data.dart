// plant sensor class
// holds info about the actual sensor values

class PlantSensorData {
  final int id; // should be initialized with id from Plant
  final String sensorId;
  final String sensorName;
  int water;
  int sunLux;
  int airTemp;
  int earthTemp;
  int humidity;

  PlantSensorData({
    required this.id,
    required this.sensorId,
    required this.sensorName,
    required this.water,
    required this.sunLux,
    required this.airTemp,
    required this.earthTemp,
    required this.humidity,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      "sensorId": sensorId,
      'sensorName': sensorName,
      'water': water,
      'sunLux': sunLux,
      'airTemp': airTemp,
      'earthTemp': earthTemp,
      'humidity': humidity,
    };
  }

  PlantSensorData copyWith({
    int? airTemp,
    int? water,
    int? sunLux,
    int? earthTemp,
    int? humidity,
    String? sensorId,
    String? sensorName,
    int? id,
  }) {
    return PlantSensorData(
      id: this.id,
      airTemp: airTemp ?? this.airTemp,
      water: water ?? this.water,
      sunLux: sunLux ?? this.sunLux,
      earthTemp: earthTemp ?? this.earthTemp,
      humidity: humidity ?? this.humidity,
      sensorId: sensorId ?? this.sensorId,
      sensorName: sensorName ?? this.sensorName,
    );
  }
}
