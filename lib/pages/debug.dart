import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// Note: Assuming these local imports are correctly set up
import './../bluetooth_helpers.dart';
import '../bluetooth/improved_device_manager.dart';
import '../data/sensor_cmd_id.dart';
import '../main.dart';
import '../data/plant.dart';

class DebugPage extends ConsumerStatefulWidget {
  // 1. Corrected: The field must be final.
  // Using List<dynamic> for flexibility based on how you declared _NewPage.
  final List<dynamic>? plantsCards;

  // 2. Corrected: Constructor should use named parameters and 'this.'
  // Made plantsCards optional (?) for now as the type is dynamic.
  const DebugPage({super.key, this.plantsCards});

  @override
  ConsumerState<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends ConsumerState<DebugPage> {
  int _selectedIndex = 0;

  // 3. CORRECTED: Removed 'static const'. This property is now a non-static getter.
  // This allows it to access 'widget.plantsCards', which is instance data.
  List<Widget> get _pages => <Widget>[
    // Index 0: Original Debug Content
    const _OriginalDebugContent(),
    // Index 1: The New Page
    // Access the instance field from the parent widget using 'widget.plantsCards'.
    // Use a null-coalescing operator (??) to provide a default empty list 
    // if plantsCards is null, to avoid errors.
    _NewPage(widget.plantsCards ?? []), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // 4. Access the corrected non-static _pages property/getter
      body: _pages.elementAt(_selectedIndex), 
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.developer_mode),
            label: 'Debug',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Log',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Sub-widgets for pages (No changes needed here) ---

/// The original debug content from your provided code.
class _OriginalDebugContent extends ConsumerWidget {
  const _OriginalDebugContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(appDatabase);
    // This will rebuild whenever connectedDevices changes.
    final connectedDevices = ref.watch(
      deviceManagerProvider.select((state) => state.connectedDevices),
    );

    if (connectedDevices.isEmpty) {
      print("no connected items");
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Connected Devices: ${connectedDevices.length}'),
          const SizedBox(height: 20),
          ...connectedDevices.map((device) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    writeToSensor(
                      db,
                      BluetoothDevice.fromId(device.deviceId),
                      SensorCmdId.testPump,
                      1,
                    );
                    print("you pressed");
                  },
                  child: Text('Test Pump - ${device.deviceId}'),
                ),
              )),
        ],
      ),
    );
  }
}

/// The new page containing a selectable list of Cards.
class _NewPage extends StatefulWidget {
  // The list passed from the parent widget remains final.
  final List plants;

  // Added super.key for best practice
  const _NewPage(this.plants, {super.key}); 

  @override
  State<_NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<_NewPage> {
  // We no longer need _selectedIndex state, as navigation handles the selection focus.
  // int? _selectedIndex; 

  @override
  Widget build(BuildContext context) {
    if (widget.plants.isEmpty) {
      return const Center(
        child: Text(
          'No items available.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0), // Add padding around the list
      itemCount: widget.plants.length,
      itemBuilder: (context, index) {
        final dynamic selectedPlant = widget.plants[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            elevation: 4, // Gives the card a nice shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell( // InkWell provides the ripple effect and onTap functionality
              borderRadius: BorderRadius.circular(10.0),
              onTap: () {
                // Navigate to the details page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // Pass the index/data to the details page
                    builder: (context) => _ItemDetailsPage(itemIndex: index, plant: selectedPlant),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Card - ${selectedPlant.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view details for ID: $index',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- New Details Page Widget ---

/// A simple page to display details for a selected item, with a back button.
class _ItemDetailsPage extends StatelessWidget {
  final int itemIndex;
  final Plant plant;

  const _ItemDetailsPage({required this.itemIndex, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar automatically provides a back arrow button (leading: back button)
      // because this page was pushed onto the navigation stack.
      appBar: AppBar(
        title: Text('Details for Item $itemIndex'),
        // No need to explicitly add a back button, the AppBar handles it.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the page for Item $itemIndex!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Place your specific item data and controls here.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Example of an explicit back button if needed elsewhere in the page:
          ],
        ),
      ),
    );
  }
}