import 'dart:typed_data';

class PlantHistory {
  final int plantId;
  final int date;
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

  factory PlantHistory.initLogValues(int id, List<int> logValues) {
    ByteData buffer = ByteData.sublistView(Uint8List.fromList(logValues));
    int unixTimestamp = buffer.getUint32(0, Endian.little);

    // // Convert to DateTime
    // DateTime dt = DateTime.fromMillisecondsSinceEpoch(
    //   unixTimestamp * 1000,
    //   isUtc: true,
    // );
    // TODO: actually return doubles, right now peripheral only returns int..
    int readValues = buffer.getUint32(4, Endian.little);
    int water = readValues & 0xFF;
    int temp = (readValues >> 16) & 0xFF;
    return PlantHistory(
      plantId: id,
      date: unixTimestamp,
      waterMl: water.toDouble(),
      temperature: temp.toDouble(),
    );
  }
}
