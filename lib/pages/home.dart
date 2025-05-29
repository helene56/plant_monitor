import 'package:flutter/material.dart';
import 'package:plant_monitor/pages/plant_stats.dart';

class MyHome extends StatefulWidget {
  final List<Map<String, dynamic>> plantsCards;
  const MyHome({super.key, required this.plantsCards});
  

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Center(
            child: Text(
              "Mine planter",
              style: TextStyle(fontSize: 30, fontFamily: 'Poppins'),
            ),
          ),
          Column(
            children: [
              Wrap(
                children:
                    widget.plantsCards
                        .map(
                          (plant) => MyPlantContainer(
                            label: plant['label'],
                            plantId: plant['plantId'],
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyPlantContainer extends StatefulWidget {
  final String label;
  final int plantId;
  const MyPlantContainer({
    super.key,
    required this.label,
    required this.plantId,
  });

  @override
  State<MyPlantContainer> createState() => _MyPlantContainerState();
}

class _MyPlantContainerState extends State<MyPlantContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPlantStat(plantId: widget.plantId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 10, 10, 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 250, 229, 212),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 3),
        ),
        width: 150,
        height: 200,
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset('./images/plant_test.png'),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
