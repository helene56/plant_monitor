// plant sensor class
// holds info about the actual sensor values

class PlantSensorData {
  // final int id; // should be initialized with id from Plant
  final int plantId;
  final String remoteId;
  final String sensorName;
  double water;
  double sunLux;
  double airTemp;
  double earthTemp;
  double humidity;

  PlantSensorData({
    required this.plantId,
    required this.remoteId,
    required this.sensorName,
    required this.water,
    required this.sunLux,
    required this.airTemp,
    required this.earthTemp,
    required this.humidity,
  });

  Map<String, Object?> toMap() {
    return {
      'plantId': plantId,
      'remoteId': remoteId,
      'sensorName': sensorName,
      'water': water,
      'sunLux': sunLux,
      'airTemp': airTemp,
      'earthTemp': earthTemp,
      'humidity': humidity,
    };
  }

  PlantSensorData copyWith({
    double? airTemp,
    double? water,
    double? sunLux,
    double? earthTemp,
    double? humidity,
    String? remoteId,
    String? sensorName,
    int? plantId,
  }) {
    return PlantSensorData(
      // id: this.id,
      plantId: this.plantId,
      airTemp: airTemp ?? this.airTemp,
      water: water ?? this.water,
      sunLux: sunLux ?? this.sunLux,
      earthTemp: earthTemp ?? this.earthTemp,
      humidity: humidity ?? this.humidity,
      remoteId: remoteId ?? this.remoteId,
      sensorName: sensorName ?? this.sensorName,
    );
  }
}
