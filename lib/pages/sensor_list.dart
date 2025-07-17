import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '/bluetooth/device_manager.dart';

class SensorList extends ConsumerStatefulWidget {
  const SensorList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SensorListState();
}

class _SensorListState extends ConsumerState<SensorList> {
  int? _value;

  @override
  Widget build(BuildContext context) {

    final allDevices = ref.watch(
      deviceManagerProvider.select((state) => state.allDevices),
    );

    if (allDevices.isNotEmpty) {
      return Wrap(
        spacing: 5.0,
        children:
            List<Widget>.generate(allDevices.length, (int index) {
              return ChoiceChip(
                label: Text(allDevices[index].deviceName),
                selected: _value == index,
                onSelected: (bool selected) {
                  setState(() {
                    _value = selected ? index : null;
                    ref
                        .read(deviceManagerProvider.notifier)
                        .selectDevice(index);
                  });
                },
              );
            }).toList(),
      );
    } else {
      return Container(); // should not show anything in case no devices are found
    }
  }
}
