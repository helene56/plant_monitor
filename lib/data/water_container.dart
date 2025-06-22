

class WaterContainer {
  final int id;
  final int currentWaterLevel;

  const WaterContainer({
    required this.id,
    required this.currentWaterLevel

  });


  Map<String, Object?> toMap() {
    return {
      'id': id,
      'currentWaterLevel': currentWaterLevel,
    };
  }
}