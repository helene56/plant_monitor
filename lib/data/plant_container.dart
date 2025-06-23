class PlantContainer {
  final int plantId;
  final int containerId;

  const PlantContainer({
    required this.plantId,
    required this.containerId

  });


  Map<String, Object?> toMap() {
    return {
      'plantId': plantId,
      'containerId': containerId,
    };
  }
}