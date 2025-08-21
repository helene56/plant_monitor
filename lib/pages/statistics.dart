import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_calendar_heatmap/flutter_calendar_heatmap.dart';
import 'dart:math';

class MyStats extends StatefulWidget {
  const MyStats({super.key});

  @override
  State<MyStats> createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  Map<DateTime, int> _data = {};
  DateTime? _selectedDate; // store picked date

  @override
  void initState() {
    _initExampleData();
    super.initState();
  }

  void _initExampleData() {
    var rng = Random();
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 200; i++) {
      DateTime date = today.subtract(Duration(days: i));
      _data[date] = rng.nextInt(6); // Random number between 0 and 5
    }
  }

  // Future<void> _pickDate() async {
  //   DateTime now = DateTime.now();
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: now,
  //     firstDate: now.subtract(const Duration(days: 365)),
  //     lastDate: now,
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       _selectedDate = DateTime(picked.year, picked.month, picked.day);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final selectedValue = _selectedDate != null ? _data[_selectedDate] ?? 0 : 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _pickDate,
            //   child: const Text("Pick a Date"),
            // ),
            // if (_selectedDate != null) ...[
            //   const SizedBox(height: 10),
            //   Text(
            //     "Selected: ${_selectedDate!.toLocal()} → Value: $selectedValue",
            //     style: const TextStyle(fontSize: 16),
            //   ),
            // ],
            const SizedBox(height: 40),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.black,
                            // fontWeight: FontWeight.bold,
                            fontSize: 14,
                          );
                          switch (value.toInt()) {
                            case 0:
                              return Text('M', style: style);
                            case 1:
                              return Text('T', style: style);
                            case 2:
                              return Text('W', style: style);
                            case 3:
                              return Text('T', style: style);
                            case 4:
                              return Text('F', style: style);
                            case 5:
                              return Text('S', style: style);
                            case 6:
                              return Text('S', style: style);
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(toY: 5, color: Colors.blue, width: 18),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 6.5,
                          color: Colors.blue,
                          width: 18,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(toY: 5, color: Colors.blue, width: 18),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 7.5,
                          color: Colors.blue,
                          width: 18,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(toY: 9, color: Colors.blue, width: 18),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: 11.5,
                          color: Colors.blue,
                          width: 18,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: 6.5,
                          color: Colors.blue,
                          width: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // // Line Chart (just for demo, show progression of last 7 days)
            // SizedBox(
            //   height: 200,
            //   child: LineChart(
            //     LineChartData(
            //       lineBarsData: [
            //         LineChartBarData(
            //           spots: List.generate(
            //             7,
            //             (i) {
            //               final day = DateTime.now().subtract(Duration(days: i));
            //               final value = _data[DateTime(day.year, day.month, day.day)] ?? 0;
            //               return FlSpot(i.toDouble(), value.toDouble());
            //             },
            //           ).reversed.toList(),
            //           isCurved: true,
            //           color: Colors.blue,
            //           barWidth: 4,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 30),

            // Heatmap showing all days
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: 1200,child: HeatMap(aspectRatio: 2.3, data: _data, itemSize: 30)),
            ),
          ],
        ),
      ),
    );
  }
}
