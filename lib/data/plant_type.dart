// this class will store ideal values for plant types.
// the Plant class will get it's values from here based on type specified.

class PlantType {
  final int id;
  final String type;
  final int waterNeedsMin;
  final int waterNeedsMax;
  final int sunLuxMin;
  final int sunLuxMax;
  final int airTempMin;
  final int airTempMax;
  final int humidityMin;
  final int humidityMax;

  const PlantType({
    required this.id,
    required this.type,
    required this.waterNeedsMin,
    required this.waterNeedsMax,
    required this.sunLuxMin,
    required this.sunLuxMax,
    required this.airTempMin,
    required this.airTempMax,
    required this.humidityMin,
    required this.humidityMax,
  });


  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type,
      'waterNeedsMin': waterNeedsMin,
      'waterNeedsMax': waterNeedsMax,
      'sunLuxMin': sunLuxMin,
      'sunLuxMax': sunLuxMax,
      'airTempMin': airTempMin,
      'airTempMax': airTempMax,
      'humidityMin': humidityMin,
      'humidityMax': humidityMax,
    };
  }
}