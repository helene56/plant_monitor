class PlantHistory {
  final String plantName;
  final String date;
  final double waterMl;
  final double temperature;

  PlantHistory({
    required this.plantName,
    required this.date,
    required this.waterMl,
    required this.temperature,
  });

  Map<String, Object?> toMap() {
    return {
      'plantName': plantName,
      'date': date,
      'waterMl': waterMl,
      'temperature': temperature,
    };
  }
}
