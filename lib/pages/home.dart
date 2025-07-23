import 'package:flutter/material.dart';
import 'package:plant_monitor/main.dart';
import 'package:plant_monitor/pages/plant_stats.dart';
import 'package:plant_monitor/data/plant.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:plant_monitor/data/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class MyHome extends ConsumerStatefulWidget {
  final List<Plant> plantsCards;
  const MyHome({super.key, required this.plantsCards});

  @override
  ConsumerState<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends ConsumerState<MyHome> {
  OverlayEntry? overlayEntry;
  bool overlayCreated = false;

  void _handleContainerPressed() {
    setState(() {
      _removeOverlay();
      overlayCreated = !overlayCreated; // toggle boolean
    });
  }

  void onDeletePlant(int plantId) {
    _handleContainerPressed();
    setState(() {
      widget.plantsCards.removeWhere((plant) => plant.id == plantId);
    });
    // remove plant from database
    deleteRecord(ref.read(appDatabase), 'plants', plantId);

    // remove any container which does not show up in plant_containers
    deleteContainer(ref.read(appDatabase));
  }

  void _showOverlay(
    BuildContext context,
    GlobalKey containerKey,
    String plantId,
    VoidCallback onDeletePlant,
  ) {
    final overlay = Overlay.of(context);
    final renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    if (overlayCreated) {
      return;
    }
    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: position.dy + 10,
            left: position.dx + 10,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.lightBlue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                  onPressed: () {
                    // show pop up ask if sure to delete
                    // use show dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('Vil du gerne slette?')],
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // delete card from database and list
                                    onDeletePlant();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('slet'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('fortryd'),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
    );
    setState(() {
      overlayCreated = true;
    });
    overlay.insert(overlayEntry!);
    // somehow remove if single tap

    // overlayEntry.remove();
  }

  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            _removeOverlay();
            setState(() {
              overlayCreated = false;
            });
          },
        ),
        SingleChildScrollView(
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
                        widget.plantsCards.map((plant) {
                          final key =
                              GlobalKey(); // unique key for each container
                          // TODO: maybe passing plant alone is enough in MyPlantContainer?
                          return MyPlantContainer(
                            plantCard: plant,
                            containerKey: key,
                            onLongPressOverlay:
                                () => _showOverlay(
                                  context,
                                  key,
                                  plant.name,
                                  () => onDeletePlant(plant.id),
                                ),
                            onContainerPressed: _handleContainerPressed,
                          );
                        }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MyPlantContainer extends StatefulWidget {
  final Plant plantCard;
  final VoidCallback onLongPressOverlay;
  final GlobalKey containerKey;
  final VoidCallback onContainerPressed;
  const MyPlantContainer({
    super.key,
    required this.plantCard,
    required this.onLongPressOverlay,
    required this.containerKey,
    required this.onContainerPressed,
  });

  @override
  State<MyPlantContainer> createState() => _MyPlantContainerState();
}

class _MyPlantContainerState extends State<MyPlantContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onContainerPressed();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPlantStat(plantCard: widget.plantCard),
          ),
        );
      },
      onLongPress: () {
        print("long press");
        Haptics.vibrate(HapticsType.light);
        // pop up saying delete
        // if pop up clicked ask are you sure, add a show dialog button with delete
        widget.onLongPressOverlay();
      },
      child: Container(
        key: widget.containerKey,
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.plantCard.name,
                    style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
