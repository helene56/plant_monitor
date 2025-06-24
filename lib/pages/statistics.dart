import 'package:flutter/material.dart';
import 'package:circle_list/circle_list.dart';

class MyStats extends StatefulWidget {
  const MyStats({super.key});

  @override
  State<MyStats> createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  @override
  // TODO: move to water page
  Widget build(BuildContext context) {
    return Center(
      child: CircleList(
        innerRadius: 60,
        outerRadius: 100,
        showInitialAnimation: false,
        innerCircleColor: Colors.white,
        outerCircleColor: Colors.blue[50],
        origin: const Offset(0, 0),
        centerWidget: Stack(
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
        children: [
          GestureDetector(
            onTap: () {
              final dynamic tooltip = _tooltipKey.currentState;
              tooltip?.ensureTooltipVisible();
              print("Tapped!");
            },
            child: Tooltip(
              key: _tooltipKey,
              message: 'hey',
              triggerMode: TooltipTriggerMode.manual, // Important!
              child: Icon(Icons.energy_savings_leaf),
            ),
          ),
          Icon(Icons.spa),
          Icon(Icons.grass),
          Icon(Icons.eco),
          // Add more icons as needed
        ],
      ),
    );
  }
}
