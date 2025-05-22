import 'package:flutter/material.dart';

class MyPlantStat extends StatelessWidget {
  final int plantId;
  const MyPlantStat({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    final GlobalKey waterDropKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          print("tapped");
          final RenderBox renderBox =
              waterDropKey.currentContext!.findRenderObject() as RenderBox;
          final Offset position = renderBox.localToGlobal(Offset.zero);
          // final Size size = renderBox.size;

          final overlay = OverlayEntry(
            builder:
                (context) => Positioned(
                  left: position.dx,
                  top: position.dy - 50,
                  child: MyOverlay(label: 'Vand'),
                ),
          );

          Overlay.of(context).insert(overlay);

          // Optionally remove after some time
          Future.delayed(Duration(seconds: 2), () {
            overlay.remove();
          });
        },
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Image.asset('./images/plant_test.png'),
                ),
                Text('id: $plantId', style: TextStyle(fontSize: 24)),
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
                    child: Text('50/100'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        key: waterDropKey,
                        child: Icon(
                          Icons.water_drop,
                          color: Color.fromARGB(
                            255,
                            120,
                            180,
                            220,
                          ), // Match Water bar
                        ),
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
                      Icon(
                        Icons.wb_sunny,
                        color: Color.fromARGB(
                          255,
                          255,
                          213,
                          79,
                        ), // Match Sunlight bar
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
                      Icon(
                        Icons.foggy,
                        color: Color.fromARGB(
                          255,
                          139,
                          193,
                          183,
                        ), // Match Moisture bar
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
                      Icon(
                        Icons.thermostat,
                        color: Color.fromARGB(
                          255,
                          255,
                          183,
                          77,
                        ), // Match Air temp bar
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
                    child: Text('50/100'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thermostat,
                        color: Color.fromARGB(
                          255,
                          188,
                          170,
                          164,
                        ), // Match Earth temp bar
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

class MyOverlay extends StatefulWidget {
  final String label;
  const MyOverlay({super.key, required this.label});

  @override
  State<MyOverlay> createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 60,
      // height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromARGB(230, 97, 97, 97), // Tooltip-like color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(widget.label, style: TextStyle(fontSize: 14, color: Colors.white)),
    );
  }
}
