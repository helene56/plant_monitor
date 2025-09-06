import 'plant_history.dart';

class StatisticsLoggingData {
  // use plantId to get the plant's asssigned name
  final Map<int, String> plantsIdentity;
  // all logging data that has been collected
  final List<PlantHistory> plantHistoryData;
  // Map<int, WeekData> weeklyData = {};
  Map<int, PlantLoggingData> loggedPlants = {}; // access plant by their plantId
  // use weeknumber as key to get the date shown in the widget - should be used in _buildDateRow
  Map<int, String> dateRow = {};

  StatisticsLoggingData({
    required this.plantsIdentity,
    required this.plantHistoryData,
  }) {
    _populateData();
  }

  final DateTime noDateSet = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  // populate loggedPlants
  void _populateData() {
    for (var log in plantHistoryData) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(
        log.date * 1000,
        isUtc: true,
      );
      int week = weekNumber(dt);
      int dayNum = dt.weekday;
      // skip where date is 0, that is equivalent to noDateSet
      if (dt == noDateSet) {
        continue;
      }

      // 1. create plantloggingdata
      loggedPlants.putIfAbsent(
        log.plantId,
        () => PlantLoggingData(
          name: plantsIdentity[log.plantId] ?? "Unknown",
          loggingData: {},
        ),
      );

      // 2. create weekdata
      var plantData = loggedPlants[log.plantId]!;
      plantData.loggingData.putIfAbsent(
        week,
        () => WeekData(water: List.filled(7, 0.0), temp: {}),
      );

      // add values
      var weekData = plantData.loggingData[week]!;
      weekData.water[dayNum - 1] += log.waterMl;
      weekData.temp[dt] = log.temperature;
    }
  }
}

class WeekData {
  List<double> water;
  Map<DateTime, double> temp;

  WeekData({required this.water, required this.temp});
}

class PlantLoggingData {
  final String name;
  final Map<int, WeekData> loggingData;

  PlantLoggingData({required this.name, required this.loggingData});
}

int weekNumber(DateTime date) {
  // First day of the year
  final firstDay = DateTime(date.year, 1, 1);
  // Days since the start of the year
  final days = date.difference(firstDay).inDays;
  // Week number (ISO weeks usually start on Monday, adjust if needed)
  return ((days + firstDay.weekday) / 7).ceil();
}
