// plant class
// optimal/static conditions for plant
class Plant {
  final int id;
  final String name;
  final String type;
  final int waterNeedsMin;
  final int waterNeedsMax;
  final int sunLuxMin;
  final int sunLuxMax;
  final int airTempMin;
  final int airTempMax;
  final int humidityMin;
  final int humidityMax;

  const Plant({
    required this.id,
    required this.name,
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

  // Convert a Plant into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
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

  // Implement toString to make it easier to see information about
  // each plant when using the print statement.
  @override
  String toString() {
    return 'Plant{\n'
        '  id: $id,\n'
        '  name: $name,\n'
        '  type: $type,\n'
        '  waterNeedsMin: $waterNeedsMin,\n'
        '  waterNeedsMax: $waterNeedsMax,\n'
        '  sunLuxMin: $sunLuxMin,\n'
        '  sunLuxMax: $sunLuxMax,\n'
        '  airTempMin: $airTempMin,\n'
        '  airTempMax: $airTempMax,\n'
        '  humidityMin: $humidityMin,\n'
        '  humidityMax: $humidityMax\n'
        '}';
  }
}


