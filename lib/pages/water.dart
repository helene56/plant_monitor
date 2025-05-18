import 'package:flutter/material.dart';

class MyWater extends StatefulWidget {
  const MyWater({super.key});

  @override
  State<MyWater> createState() => _MyWaterState();
}

class _MyWaterState extends State<MyWater> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('my text for water container'));
  }
}