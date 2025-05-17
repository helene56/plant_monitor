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
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Column(
              children: [
                Wrap(
                  children: [
                    MyPlantContainer(label: 'gummi'),
                    MyPlantContainer(label: 'banan'),
                    MyPlantContainer(label: 'test',)
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyPlantContainer extends StatelessWidget {
  final String label;
  const MyPlantContainer({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 250, 229, 212),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      width: 150,
      height: 200,
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              './images/plant_test.png',
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}