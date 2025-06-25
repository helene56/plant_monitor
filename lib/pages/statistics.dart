import 'package:flutter/material.dart';
import 'dart:math';

class MyStats extends StatefulWidget {
  const MyStats({super.key});

  @override
  State<MyStats> createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  @override
  // TODO: move to water page
  Widget build(BuildContext context) {
    return Center(child: CustomCircleIcons());
  }
}

class CustomCircleIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Configuration
    final double outerRadius = 100;
    final double iconRadius = 24;
    final double iconCircleRadius = outerRadius * 0.8;
    final List<IconData> icons = [
      Icons.home,
      Icons.favorite,
      Icons.settings,
      Icons.person,
      Icons.lightbulb,
      Icons.abc,
    ];

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
                      value: 0.5, // 50% fill
                      strokeWidth: 8,
                      backgroundColor: Colors.blue[50],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Icon(Icons.water_drop, size: 70, color: Colors.blue),
                  Positioned(
                    top: 30,
                    child: Text(
                      '50%',
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
                child: Container(
                  width: iconRadius * 2,
                  height: iconRadius * 2,
                  child: Tooltip(
                    message: 'hey',
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    child: Icon(icons[i], size: 28, color: Colors.blueAccent),
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
