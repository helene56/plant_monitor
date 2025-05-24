
class Plant {
  final String name;
  final String type;
  final String waterNeeds;
  final List<int> sunLux;
  final List<int> temp;
  final List<int> humidity;

  Plant({required this.name, required this.type, required this.waterNeeds, required this.sunLux, required this.temp, required this.humidity});
}

// note: in case of high humidity the plant will need less water.
List<Plant> plants = [
  Plant(name: 'Gummi træ', type: 'ficus elastica', waterNeeds: 'Medium', sunLux: [250, 1000], temp: [18, 27], humidity: [50, 80]),
];
