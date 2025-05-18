import 'package:flutter/material.dart';

class MyStats extends StatefulWidget {
  const MyStats({super.key});

  @override
  State<MyStats> createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('my text for Stats'));
  }
}