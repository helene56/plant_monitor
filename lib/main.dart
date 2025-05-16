import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xfff6f9f8),
        body: Column(
          mainAxisAlignment:
              MainAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Center(
              child: Text(
                "Mine planter",
                style: TextStyle(fontSize: 30, fontFamily: 'Poppins'),
              ),
            ),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                PlantContainer(
                  label: 'gummi',
                ),
                PlantContainer(
                  label: 'succi',
                ),
                PlantContainer(
                  label: 'virkelig virkelig langt',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlantContainer extends StatelessWidget {
  final String label;

  const PlantContainer({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // get text width
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double textWidth = painter.width;

    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 250, 229, 212),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 3)
      ),
      width: textWidth + 100,
      height: 70.0,
      child: Row(
        children: [
          Image.asset('./images/plant_test.png'),
          Expanded(
            flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                ),
              ),
          ),
        ],
      ),
    );
  }
}
