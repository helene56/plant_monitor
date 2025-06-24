import 'package:flutter/material.dart';
import 'package:circle_list/circle_list.dart';

class MyStats extends StatefulWidget {
  const MyStats({super.key});

  @override
  State<MyStats> createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
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
          Tooltip(
            preferBelow: true,
            triggerMode: TooltipTriggerMode.tap,
            message: 'hey',
            child: SizedBox(
              height: 20,
              width: 20,
              child: GestureDetector(
                // behavior: HitTestBehavior.opaque, // Makes the entire padded area tappable
                onTap: () {
                  print("heyy you clicked.");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(onPressed: (){}, icon: Icon(Icons.energy_savings_leaf)),
                ),
              ),
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
