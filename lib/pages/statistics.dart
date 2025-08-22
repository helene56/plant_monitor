import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyStats extends StatefulWidget {
  const MyStats({super.key});

  @override
  State<MyStats> createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  _SelectedButton _selectedButton = _SelectedButton.water;
  bool _showAvg = false;

  void _toggleAvg() {
    setState(() {
      _showAvg = !_showAvg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: OrientationBuilder(
        builder: (context, orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          if (isLandscape) {
            return _buildLandscapeLayout();
          } else {
            return _buildPortraitLayout();
          }
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildDateRow(),
          const SizedBox(height: 40),
          _buildChartCard(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildDateRow(),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: _buildChartCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
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
    );
  }

  Widget _buildChartCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color.fromARGB(255, 255, 245, 235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Use Expanded instead of AspectRatio to make the chart flexible
            SizedBox(
              height: 250, // You can adjust this height as needed
              child:
                  _selectedButton == _SelectedButton.water
                      ? const _DailyBarChart()
                      : _MonthlyLineChart(showAvg: _showAvg),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                        isSelected:
                            _selectedButton == _SelectedButton.temperature,
                        icon: Icons.thermostat,
                        onPressed: () {
                          setState(() {
                            _selectedButton = _SelectedButton.temperature;
                          });
                        },
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    child: Opacity(
                      opacity:
                          _selectedButton == _SelectedButton.temperature
                              ? 1.0
                              : 0.0,
                      child: _AverageButton(
                        showAvg: _showAvg,
                        onPressed: _toggleAvg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// All other classes (_SelectedButton, _SelectableIconButton, _AverageButton,
// _DailyBarChart, _MonthlyLineChart) remain unchanged.
// Paste them below this code block to complete the file.

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
        color: isSelected ? const Color(0xFF66CC88) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFFB0B0B0),
        ),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onPressed: onPressed,
      ),
    );
  }
}

class _AverageButton extends StatelessWidget {
  const _AverageButton({required this.showAvg, required this.onPressed});

  final bool showAvg;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 34,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          'avg',
          style: TextStyle(
            fontSize: 12,
            color: showAvg ? Colors.black.withAlpha(127) : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  const _DailyBarChart();

  // how many times watered or how much water used?
  // decide to show how much water was used in ml

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withAlpha(77), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(color: Colors.black, fontSize: 12);
                const unitStyle = TextStyle(color: Colors.black, fontSize: 12);

                if (value == meta.max) {
                  return Text('mL', style: unitStyle);
                }
                return Text(value.toStringAsFixed(0), style: style);
              },
            ),
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
                    return const Text('O', style: style);
                  case 3:
                    return const Text('T', style: style);
                  case 4:
                    return const Text('F', style: style);
                  case 5:
                    return const Text('L', style: style);
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
            barRods: [
              BarChartRodData(
                toY: 5,
                color: const Color(0xFF66CC88),
                width: 18,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 6.5,
                color: const Color(0xFF66CC88),
                width: 18,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 5,
                color: const Color(0xFF66CC88),
                width: 18,
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 7.5,
                color: const Color(0xFF66CC88),
                width: 18,
              ),
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 9,
                color: const Color(0xFF66CC88),
                width: 18,
              ),
            ],
          ),

          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(
                toY: 11.5,
                color: const Color(0xFF66CC88),
                width: 18,
              ),
            ],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [
              BarChartRodData(
                toY: 6.5,
                color: const Color(0xFF66CC88),
                width: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyLineChart extends StatelessWidget {
  const _MonthlyLineChart({required this.showAvg});

  final bool showAvg;
  static const int mondayLimit = 1;
  static const int tuesdayLimit = 3;
  static const int wednesdayLimit = 5;
  static const int thursdayLimit = 7;
  static const int fridayLimit = 9;
  static const int saturdayLimit = 11;
  static const int sundayLimit = 13;

  @override
  Widget build(BuildContext context) {
    return LineChart(showAvg ? _avgData() : _mainData());
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);
    switch (value.toInt()) {
      case mondayLimit:
        return const Text('M', style: style);
      case tuesdayLimit:
        return const Text('T', style: style);
      case wednesdayLimit:
        return const Text('O', style: style);
      case thursdayLimit:
        return const Text('T', style: style);
      case fridayLimit:
        return const Text('F', style: style);
      case saturdayLimit:
        return const Text('L', style: style);
      case sundayLimit:
        return const Text('S', style: style);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);
    if (value % 2 == 0) {
      return Text(
        value.toStringAsFixed(0),
        style: style,
        textAlign: TextAlign.left,
      );
    }
    return const SizedBox.shrink();
  }

  LineChartData _mainData() {
    final List<Color> gradientColors = [
      const Color(0xFF66CC88),
      const Color(0xFF66CC88).withAlpha(127),
    ];

    return LineChartData(
      // Enable line touch data
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final String value = touchedSpot.y.toStringAsFixed(2);
              return LineTooltipItem(
                value,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
        getTouchedSpotIndicator: (
          LineChartBarData barData,
          List<int> spotIndexes,
        ) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(color: Color(0xFF66CC88), strokeWidth: 2),
              FlDotData(
                show: true,
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 8,
                      color: Color(0xFF66CC88),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.withAlpha(77), strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          if (value % 2 == 0) {
            return FlLine(color: Colors.grey.withAlpha(77), strokeWidth: 1);
          }
          return FlLine(color: Colors.transparent);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
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
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 14,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 2),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 6),
            FlSpot(9.5, 3),
            FlSpot(14, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors:
                  gradientColors.map((color) => color.withAlpha(77)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _avgData() {
    final List<Color> gradientColors = [
      const Color(0xFF66CC88),
      const Color(0xFF66CC88).withAlpha(127),
    ];

    return LineChartData(
      // Enable line touch data
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final String value = touchedSpot.y.toStringAsFixed(2);
              return LineTooltipItem(
                value,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
        getTouchedSpotIndicator: (
          LineChartBarData barData,
          List<int> spotIndexes,
        ) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(color: Color(0xFF66CC88), strokeWidth: 2),
              FlDotData(
                show: true,
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 8,
                      color: Color(0xFF66CC88),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(
        show: true,
        verticalInterval: 1.0,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.withAlpha(77), strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          if (value % 2 == 0) {
            return FlLine(color: Colors.grey.withAlpha(77), strokeWidth: 1);
          }
          return FlLine(color: Colors.transparent);
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
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 14,
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
            FlSpot(14, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(
                begin: gradientColors[0],
                end: gradientColors[1],
              ).lerp(0.2)!,
              ColorTween(
                begin: gradientColors[0],
                end: gradientColors[1],
              ).lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(
                  begin: gradientColors[0],
                  end: gradientColors[1],
                ).lerp(0.2)!.withAlpha(25),
                ColorTween(
                  begin: gradientColors[0],
                  end: gradientColors[1],
                ).lerp(0.2)!.withAlpha(25),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
