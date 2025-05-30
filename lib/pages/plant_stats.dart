import 'package:flutter/material.dart';
import 'package:plant_monitor/data/plant.dart';

class MyPlantStat extends StatefulWidget {
  final int plantId;
  final Plant plantCard;
  const MyPlantStat({super.key, required this.plantId, required this.plantCard});

  @override
  State<MyPlantStat> createState() => _MyPlantStatState();
}

class _MyPlantStatState extends State<MyPlantStat> {
  bool showingToolTips = false;
  
  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> waterKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> sunKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> moistureKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> airTempKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> earthTempKey = GlobalKey<TooltipState>();

    List tooltips = [waterKey, sunKey, moistureKey, airTempKey, earthTempKey];

    int waterMax = widget.plantCard.waterNeedsMax;

    return GestureDetector(
      onTap: () async {
        if (showingToolTips) return;
        showingToolTips = true;

        for (var tool in tooltips) {
          tool.currentState?.ensureTooltipVisible();
          await Future.delayed(Duration(milliseconds: 200), () {
            Tooltip.dismissAllToolTips();
          });
        }

        showingToolTips = false;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Image.asset('./images/plant_test.png'),
                ),
                Text('id: ${widget.plantId}', style: TextStyle(fontSize: 24)),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 245, 235),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 3),
              ),
              width: 350,
              height: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Text('Vand'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('50/$waterMax'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TooltipIcon(
                        tooltipkey: waterKey,
                        iconName: 'Vand',
                        iconSymbol: Icons.water_drop,
                        color: Color.fromARGB(255, 120, 180, 220),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 260,
                        child: LinearProgressIndicator(
                          backgroundColor: Color.fromARGB(
                            85,
                            120,
                            180,
                            220,
                          ), // Water bg
                          borderRadius: BorderRadius.circular(25),
                          color: Color.fromARGB(
                            255,
                            120,
                            180,
                            220,
                          ), // Water bar
                          minHeight: 20,
                          value: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Text('Sollys'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('50/100'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TooltipIcon(
                        tooltipkey: sunKey,
                        iconName: 'Sollys',
                        iconSymbol: Icons.wb_sunny,
                        color: Color.fromARGB(255, 255, 213, 79),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 260,
                        child: LinearProgressIndicator(
                          backgroundColor: Color.fromARGB(
                            85,
                            255,
                            213,
                            79,
                          ), // Sunlight bg
                          borderRadius: BorderRadius.circular(25),
                          color: Color.fromARGB(
                            255,
                            255,
                            213,
                            79,
                          ), // Sunlight bar
                          minHeight: 20,
                          value: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Text('Fugt'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('50/100'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TooltipIcon(
                        tooltipkey: moistureKey,
                        iconName: 'Fugt',
                        iconSymbol: Icons.foggy,
                        color: Color.fromARGB(255, 139, 193, 183),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 260,
                        child: LinearProgressIndicator(
                          backgroundColor: Color.fromARGB(
                            85,
                            139,
                            193,
                            183,
                          ), // Moisture bg
                          borderRadius: BorderRadius.circular(25),
                          color: Color.fromARGB(
                            255,
                            139,
                            193,
                            183,
                          ), // Moisture bar
                          minHeight: 20,
                          value: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Text('Luft temperatur'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('50/100'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TooltipIcon(
                        tooltipkey: airTempKey,
                        iconName: 'Luft temperatur',
                        iconSymbol: Icons.thermostat,
                        color: Color.fromARGB(255, 255, 183, 77),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 260,
                        child: LinearProgressIndicator(
                          backgroundColor: Color.fromARGB(
                            85,
                            255,
                            183,
                            77,
                          ), // Air temp bg
                          borderRadius: BorderRadius.circular(25),
                          color: Color.fromARGB(
                            255,
                            255,
                            183,
                            77,
                          ), // Air temp bar
                          minHeight: 20,
                          value: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Text('Jord temperatur'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('50℃'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TooltipIcon(
                        tooltipkey: earthTempKey,
                        iconName: 'Jord temperatur',
                        iconSymbol: Icons.thermostat,
                        color: Color.fromARGB(255, 188, 170, 164),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 260,
                        child: LinearProgressIndicator(
                          backgroundColor: Color.fromARGB(
                            85,
                            188,
                            170,
                            164,
                          ), // Earth temp bg
                          borderRadius: BorderRadius.circular(25),
                          color: Color.fromARGB(
                            255,
                            188,
                            170,
                            164,
                          ), // Earth temp bar
                          minHeight: 20,
                          value: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TooltipIcon extends StatelessWidget {
  final GlobalKey<TooltipState> tooltipkey;
  final String iconName;
  final IconData iconSymbol;
  final Color color;
  const TooltipIcon({
    super.key,
    required this.tooltipkey,
    required this.iconName,
    required this.iconSymbol,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: tooltipkey,
      message: iconName,
      preferBelow: false,
      child: GestureDetector(
        onTap: () {
          tooltipkey.currentState?.ensureTooltipVisible();
          Future.delayed(Duration(milliseconds: 400), () {
            Tooltip.dismissAllToolTips();
          });
        }, // Absorbs tap, does nothing
        child: Icon(
          iconSymbol,
          color: color, // Match Water bar
        ),
      ),
    );
  }
}
