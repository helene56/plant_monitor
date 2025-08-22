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
            const SizedBox(height: 40),
            const Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // DropdownButton<String>(
            //   value: _selectedDropdownValue,
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       _selectedDropdownValue = newValue;
            //     });
            //   },
            //   items: _dropdownItems.map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),
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
                const Text(
                  'Uge 1',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // TODO: Implement logic to switch to next data set
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            const SizedBox(height: 200, child: _DailyBarChart()),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SelectableIconButton(
                  isSelected: _selectedButton == _SelectedButton.water,
                  icon: Icons.water_drop,
                  onPressed: () {
                    setState(() {
                      _selectedButton = _SelectedButton.water;
                    });
                  },
                ),
                const SizedBox(width: 20),
                _SelectableIconButton(
                  isSelected: _selectedButton == _SelectedButton.temperature,
                  icon: Icons.thermostat,
                  onPressed: () {
                    setState(() {
                      _selectedButton = _SelectedButton.temperature;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            _MonthlyLineChart(),
          ],
        ),
      ),
    );
  }
}

enum _SelectedButton { water, temperature }

class _SelectableIconButton extends StatelessWidget {
  const _SelectableIconButton({
    required this.isSelected,
    required this.icon,
    required this.onPressed,
  });

  final bool isSelected;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.lightBlue[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [],
      ),
      child: IconButton(
        icon: Icon(icon),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onPressed: onPressed,
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  const _DailyBarChart();

  @override
  Widget build(BuildContext context) {
    return BarChart(
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
                const style = TextStyle(color: Colors.black, fontSize: 14);
                switch (value.toInt()) {
                  case 0:
                    return const Text('M', style: style);
                  case 1:
                    return const Text('T', style: style);
                  case 2:
                    return const Text('W', style: style);
                  case 3:
                    return const Text('T', style: style);
                  case 4:
                    return const Text('F', style: style);
                  case 5:
                    return const Text('S', style: style);
                  case 6:
                    return const Text('S', style: style);
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
            barRods: [BarChartRodData(toY: 5, color: Colors.blue, width: 18)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 6.5, color: Colors.blue, width: 18)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: 5, color: Colors.blue, width: 18)],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: 7.5, color: Colors.blue, width: 18)],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [BarChartRodData(toY: 9, color: Colors.blue, width: 18)],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(toY: 11.5, color: Colors.blue, width: 18),
            ],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [BarChartRodData(toY: 6.5, color: Colors.blue, width: 18)],
          ),
        ],
      ),
    );
  }
}


class _MonthlyLineChart extends StatefulWidget {
  const _MonthlyLineChart();

  @override
  State<_MonthlyLineChart> createState() => _MonthlyLineChartState();
}

class _MonthlyLineChartState extends State<_MonthlyLineChart> {
  bool showAvg = false;

  final List<Color> gradientColors = [
    const Color(0xFF00C7FF),
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? _avgData() : _mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.black.withValues(alpha: 0.5) : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    switch (value.toInt()) {
      case 2:
        return const Text('MAR', style: style);
      case 5:
        return const Text('JUN', style: style);
      case 8:
        return const Text('SEP', style: style);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return const SizedBox.shrink();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData _mainData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.transparent,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 1),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withValues(alpha: 0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.transparent,
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: _bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 1),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withValues(alpha: 0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}