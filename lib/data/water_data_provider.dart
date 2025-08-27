import 'database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/data/water_container.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:plant_monitor/bluetooth_helpers.dart';

class WaterDataState {
  final List<double> waterLevel;
  final List<int> containerIds;
  final Map<int, List<String>> plantInfo;

  WaterDataState({
    required this.waterLevel,
    required this.containerIds,
    required this.plantInfo,
  });

  WaterDataState copyWith({
    List<double>? waterLevel,
    List<int>? containerIds,
    Map<int, List<String>>? plantInfo,
  }) {
    return WaterDataState(
      waterLevel: waterLevel ?? this.waterLevel,
      containerIds: containerIds ?? this.containerIds,
      plantInfo: plantInfo ?? this.plantInfo,
    );
  }
}

class WaterDataNotifier extends StateNotifier<WaterDataState> {
  WaterDataNotifier(this.ref)
    : super(WaterDataState(waterLevel: [], containerIds: [], plantInfo: {})) {
    loadAll();
  }

  final Ref ref;

  Future<void> loadAll() async {
    await lastKnownPumpStatus();
    await getPlants();

  }

  Future<void> lastKnownPumpStatus() async {
    final db = ref.read(appDatabase);
    List<double> newWaterLevel = [];
    List<int> currentContainerId = [];
    List<WaterContainer> waterContainers = await getAllWaterContainers(db);
    for (var container in waterContainers) {
      newWaterLevel.add(container.currentWaterLevel);
      currentContainerId.add(container.id);
    }
    state = state.copyWith(
      waterLevel: newWaterLevel,
      containerIds: currentContainerId,
    );
  }

  Future<void> getPlants() async {
    final db = ref.read(appDatabase);


    Map<int, List<String>> plantRelation = {
      for (var container in state.containerIds) container: <String>[],
    };
    // get all plants
    var getPlants = await allPlants(db);
    // look up in db plant_containers, what container each plant has
    var getPlantContainerRelation = await getAllPlantContainers(db);
    // add plant to correct container displayed
    for (var plant in getPlants) {
      for (var containerRelation in getPlantContainerRelation) {
        if (plant.id == containerRelation.plantId) {
          plantRelation[containerRelation.containerId]?.add(plant.name);
        }
      }
    }
    state = state.copyWith(plantInfo: plantRelation);
  }

  Future<void> initializeSensor() async {
    // TODO: might be a good idea to actually only do this if it is connected to bluetooth,
    // so maybe watch a state to determine if connected?
    // You can implement sensor logic here if needed, similar to your original initializeSensor
    // For now, this is a placeholder
    // If you want to update waterLevel based on sensors, do it here and call state = state.copyWith(waterLevel: ...)
    List<double> newWaterLevel = [];
    final db = ref.read(appDatabase);
  
    List<PlantSensorData> allSensors = await getAllSensors(db);
    List<String> selectSensors = await getSelectedSensors(db, allSensors);

    for (var remoteId in selectSensors) {
      final double? waterOutput = await subscibeGetPumpWater(
        BluetoothDevice.fromId(remoteId),
        db,
      );
      if (waterOutput == -1) {
        return;
      }
      newWaterLevel.add(waterOutput!);
    }

    // Subtract newWaterLevel from the current state.waterLevel, element-wise
    List<double> updatedWaterLevel = List.generate(
      state.waterLevel.length,
      (i) => state.waterLevel[i] - (i < newWaterLevel.length ? newWaterLevel[i] : 0),
    );

    state = state.copyWith(waterLevel: updatedWaterLevel);
  }
}

final waterDataProvider =
    StateNotifierProvider<WaterDataNotifier, WaterDataState>(
      (ref) => WaterDataNotifier(ref),
    );
