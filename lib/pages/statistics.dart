import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyStats extends StatefulWidget {
  const MyStats({super.key});

  @override
  State<MyStats> createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  final List<String> _dropdownItems = ['choice 1', 'choice 2'];
  String? _selectedDropdownValue;
  _SelectedButton _selectedButton = _SelectedButton.water;

  @override
  void initState() {
    super.initState();
    _selectedDropdownValue = _dropdownItems.first;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedDropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDropdownValue = newValue;
                });
              },
              items: _dropdownItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    // TODO: Implement logic to switch to previous data set
                  },
                ),
                const Text('Daily Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // TODO: Implement logic to switch to next data set
                  },
                ),
              ],
            ),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: _selectedButton == _SelectedButton.water ? Colors.lightBlue[100] : Colors.transparent,
                  // Removed elevation
                  borderRadius: BorderRadius.circular(24),
                  child: IconButton(
                    icon: const Icon(Icons.water_drop),
                    // Set highlight and splash colors to transparent to remove the on-press effect
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      setState(() {
                        _selectedButton = _SelectedButton.water;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Material(
                  color: _selectedButton == _SelectedButton.temperature ? Colors.lightBlue[100] : Colors.transparent,
                  // Removed elevation
                  borderRadius: BorderRadius.circular(24),
                  child: IconButton(
                    icon: const Icon(Icons.thermostat),
                    // Set highlight and splash colors to transparent to remove the on-press effect
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      setState(() {
                        _selectedButton = _SelectedButton.temperature;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

enum _SelectedButton { water, temperature }