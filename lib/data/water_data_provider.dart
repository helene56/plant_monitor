import 'database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/data/water_container.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:plant_monitor/bluetooth_helpers.dart';

class WaterDataState {
  final List<int> statuses;
  final List<int> containerIds;
  final Map<int, List<String>> plantInfo;

  WaterDataState({
    required this.statuses,
    required this.containerIds,
    required this.plantInfo,
  });

  WaterDataState copyWith({
    List<int>? statuses,
    List<int>? containerIds,
    Map<int, List<String>>? plantInfo,
  }) {
    return WaterDataState(
      statuses: statuses ?? this.statuses,
      containerIds: containerIds ?? this.containerIds,
      plantInfo: plantInfo ?? this.plantInfo,
    );
  }
}

class WaterDataNotifier extends StateNotifier<WaterDataState> {
  WaterDataNotifier(this.ref)
    : super(WaterDataState(statuses: [], containerIds: [], plantInfo: {})) {
    loadAll();
  }

  final Ref ref;

  Future<void> loadAll() async {
    await lastKnownPumpStatus();
    await getPlants();

  }

  Future<void> lastKnownPumpStatus() async {
    final db = ref.read(appDatabase);
    List<int> newStatuses = [];
    List<int> currentContainerId = [];
    List<WaterContainer> waterContainers = await getAllWaterContainers(db);
    for (var container in waterContainers) {
      newStatuses.add(container.currentWaterLevel);
      currentContainerId.add(container.id);
    }
    state = state.copyWith(
      statuses: newStatuses,
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
    // If you want to update statuses based on sensors, do it here and call state = state.copyWith(statuses: ...)
    List<int> newStatuses = [];
    final db = ref.read(appDatabase);

    List<PlantSensorData> allSensors = await getAllSensors(db);
    List<String> selectSensors = await getSelectedSensors(db, allSensors);

    for (var sensorId in selectSensors) {
      final int? status = await subscibeGetPumpStatus(
        BluetoothDevice.fromId(sensorId),
        db,
      );
      if (status == -1) {
        return;
      }
      newStatuses.add(status!);
    }

    state = state.copyWith(statuses: newStatuses);
  }
}

final waterDataProvider =
    StateNotifierProvider<WaterDataNotifier, WaterDataState>(
      (ref) => WaterDataNotifier(ref),
    );
