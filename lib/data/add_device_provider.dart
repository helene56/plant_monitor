import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


final addPlantSensor = StateProvider<bool>((ref) {
  return false;
});


final chipSelectSensor = StateProvider<bool>((ref) {
  return true;
});