import 'package:flutter/material.dart';


class MyStats extends StatefulWidget {
  const MyStats({super.key});

  @override
  State<MyStats> createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  @override
  // TODO: move to water page
  Widget build(BuildContext context) {
    return Center(child: Text('this is the statitistics'));
  }
}


