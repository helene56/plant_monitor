class PlantHistory {
  final int plantId;
  final String date;
  final double waterMl;
  final double temperature;

  PlantHistory({
    required this.plantId,
    required this.date,
    required this.waterMl,
    required this.temperature,
  });

  Map<String, Object?> toMap() {
    return {
      'plantId': plantId,
      'date': date,
      'waterMl': waterMl,
      'temperature': temperature,
    };
  }
}
