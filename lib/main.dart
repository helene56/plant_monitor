import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    int currentPageindex = 0;

  final List<Widget> widgetOptions = [
      MyHome(),
    ];


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge(
                child: Icon(
                  Icons.notifications_sharp,
                ),
              ),
              label: 'Notifications',
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('2'),
                child: Icon(
                  Icons.messenger_sharp,
                ),
              ),
              label: 'Messages',
            ),
          ],
          onDestinationSelected: (int index) {
            setState(() {
              currentPageindex = index;
            });
          },
        ),
        backgroundColor: Color(0xfff6f9f8),
        body:  widgetOptions[currentPageindex],
      ),
    );
  }
}
