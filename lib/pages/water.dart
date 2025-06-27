import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../data/water_data_provider.dart';

// TODO: better naming in this file..

class MyWater extends ConsumerStatefulWidget {
  const MyWater({super.key});

  @override
  ConsumerState<MyWater> createState() => _MywaterFill();
}

class _MywaterFill extends ConsumerState<MyWater> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // initialize sensor when building widget
      ref.read(waterDataProvider.notifier).initializeSensor();
    });
  }

  @override
  Widget build(BuildContext context) {
    final waterData = ref.watch(waterDataProvider);

    return SafeArea(
      child: Stack(
        children: [
          // The scrollable list
          Positioned.fill(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: waterData.containerIds.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.all(15),
                  child: Center(
                    child: CustomCircleIcons(
                      plantRelation: waterData.plantInfo,
                      waterFill: waterData.statuses[index],
                      relationKey: waterData.containerIds[index],
                    ),
                  ),
                );
              },
            ),
          ),
          // The refresh button in the top right corner
          Positioned(
            top: 0,
            right: 10,
            child: SafeArea(
              child: IconButton(
                onPressed: () {
                  ref.read(waterDataProvider.notifier).initializeSensor();
                },
                icon: Icon(Icons.refresh),
                iconSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCircleIcons extends StatelessWidget {
  final int waterFill;
  final Map<int, List<String>> plantRelation;
  final int relationKey;
  const CustomCircleIcons({
    super.key,
    required this.waterFill,
    required this.plantRelation,
    required this.relationKey,
  });

  @override
  Widget build(BuildContext context) {
    // Configuration
    final List<MaterialColor> colorSelector = [
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.orange,
    ];
    final int maxColors = colorSelector.length;
    final double outerRadius = 100;
    final double iconRadius = 24;
    final double iconCircleRadius = outerRadius * 0.8;
    final List<IconData> icons = [];
    if (plantRelation[relationKey] != null) {
      for (var _ in plantRelation[relationKey]!) {
        icons.add(Icons.eco);
      }
    }

    return Center(
      child: SizedBox(
        width: outerRadius * 2,
        height: outerRadius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle visual (optional)
            Container(
              width: outerRadius * 2,
              height: outerRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue[50]!, width: 40),
              ),
            ),
            // Center icon
            Container(
              width: iconRadius * 2 * 2,
              height: iconRadius * 2 * 2,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: waterFill / 100, // 50% fill
                      strokeWidth: 8,
                      backgroundColor: Colors.blue[50],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Icon(Icons.water_drop, size: 70, color: Colors.blue),
                  Positioned(
                    top: 30,
                    child: Text(
                      '$waterFill%',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Icons around the circle
            ...List.generate(icons.length, (i) {
              final double angle = (2 * pi / icons.length) * i;
              final double x = iconCircleRadius * cos(angle);
              final double y = iconCircleRadius * sin(angle);
              return Positioned(
                left: outerRadius + x - iconRadius,
                top: outerRadius + y - iconRadius,
                child: SizedBox(
                  width: iconRadius * 2,
                  height: iconRadius * 2,
                  child: Tooltip(
                    message:
                        plantRelation[relationKey] != null
                            ? plantRelation[relationKey]![i]
                            : '',
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    child: Icon(
                      icons[i],
                      size: 28,
                      color: colorSelector[i % maxColors],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
