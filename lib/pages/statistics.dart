import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_monitor/main.dart';
import '../data/database_helper.dart';
import '../data/plant_history.dart';

class MyStats extends ConsumerStatefulWidget {
  const MyStats({super.key});

  @override
  ConsumerState<MyStats> createState() => _MyStatsState();
}

enum _SelectedButton { water, temperature }

class _MyStatsState extends ConsumerState<MyStats> {
  late String _selectedPlantKey = '';
  _SelectedButton _selectedButton = _SelectedButton.water;
  bool _showAvg = false;
  int dataIdx = 0;
  late final Map<String, Map<DateTime, Map<String, List<double>>>> logData;
  final DateTime noDateSet = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );
  @override
  void initState() {
    super.initState();
    logData = {
      // "emptyplant": {
      //   "0000-00-00": {
      //     "temperature": [0.0],
      //     "water": [0.0],
      //   },
      // },
    };
    _initializeData();
  }

  void _initializeData() async {
    Map<int, String> plants = await getPlantSummaries(ref.read(appDatabase));
    // get plants and their id
    // get associated data from planthistory with plant id
    List<PlantHistory> plantHistoryData = await getPlantHistory(
      ref.read(appDatabase),
    );
    String plantName;
    // get date from history, as first key
    // then get plantname from plants, where both have same plantid, this is the next key
    // then add a list with values from water to this last key
    for (var log in plantHistoryData) {
      plantName = plants[log.plantId] ?? '';

      DateTime dt = DateTime.fromMillisecondsSinceEpoch(
        log.date * 1000,
        isUtc: true,
      );
      // String date = "${dt.day}/${dt.month}/${dt.year}";

      _addLog(dt, plantName, log.temperature, log.waterMl);
    }

    int desiredLength = 7;

    logData.forEach((plants, date) {
      date.forEach((plantName, properties) {
        properties.forEach((key, list) {
          // Cap data to 7 entries
          if (list.length > desiredLength) {
            properties[key] = list.sublist(list.length - desiredLength);
          }
          // Pad with 0.0 if fewer than 7
          else if (list.length < desiredLength) {
            list.addAll(List.filled(desiredLength - list.length, 0.0));
          }
        });
      });
    });

    setState(() {
      _selectedPlantKey = plants.isNotEmpty ? plants.values.first : '';
    });
  }

  void _onPlantSelected(String plantKey) {
    setState(() {
      _selectedPlantKey = plantKey;
    });
  }

  void _toggleAvg() {
    setState(() {
      _showAvg = !_showAvg;
    });
  }

  void _ensureList(String plantName, DateTime date, String key) {
    logData.putIfAbsent(plantName, () => {});
    logData[plantName]!.putIfAbsent(date, () => {});
    logData[plantName]![date]!.putIfAbsent(key, () => <double>[]);
  }

  void _addLog(DateTime date, String plantName, double tempVal, double watVal) {
    _ensureList(plantName, date, 'temperature');
    _ensureList(plantName, date, 'water');

    // add values
    logData[plantName]![date]!['water']!.add(watVal);
    logData[plantName]![date]!['temperature']!.add(tempVal);
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, Map<String, List<double>>> currentPlantData;
    final List<String> plantKeys = logData.keys.toList();

    if (logData.isEmpty) {
      // fallback if logData is not loaded or empty
      currentPlantData = {
        noDateSet: {
          'temperature': [0.0],
          'water': [0.0],
        },
      };
    } else {
      final String selectedPlantLog = plantKeys[dataIdx];
      currentPlantData = logData[selectedPlantLog]!;
    }

    return SingleChildScrollView(
      child: OrientationBuilder(
        builder: (context, orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          if (isLandscape) {
            return _buildLandscapeLayout(currentPlantData);
          } else {
            return _buildPortraitLayout(currentPlantData, plantKeys);
          }
        },
      ),
    );
  }

  Widget _buildPortraitLayout(
    Map<DateTime, Map<String, List<double>>> currentPlantData,
    final List<String> plantKeys,
  ) {
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
          _buildChartCard(currentPlantData),
          const SizedBox(height: 20),
          _PlantCard(
            plantKeys: plantKeys,
            onPlantSelected: _onPlantSelected,
            selectedPlantKey: _selectedPlantKey,
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    Map<DateTime, Map<String, List<double>>> currentPlantData,
  ) {
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
            Expanded(flex: 3, child: _buildChartCard(currentPlantData)),
          ],
        ),
      ),
    );
  }

  // todo here
  Widget _buildDateRow() {
    final List<DateTime> keysWeek =
        logData.isNotEmpty
            ? logData[_selectedPlantKey]!.keys.toList()
            : [noDateSet];

    final date =
        "${keysWeek[dataIdx].day}/${keysWeek[dataIdx].month}/${keysWeek[dataIdx].year}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              if (dataIdx > 0) {
                dataIdx--;
              }
            });
          },
        ),
        Text(date, style: const TextStyle(fontSize: 18)),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              if (dataIdx < keysWeek.length - 1) {
                dataIdx++;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildChartCard(
    Map<DateTime, Map<String, List<double>>> currentPlantData,
  ) {
    List<double> plantwaterValues;
    List<double> plantTempValues;
    DateTime selectedDate;

    if (_selectedPlantKey.isNotEmpty) {
      final List<DateTime> plantDates =
          logData[_selectedPlantKey]!.keys.toList();
      selectedDate = plantDates[dataIdx];
      plantwaterValues =
          currentPlantData[plantDates[dataIdx]]?['water'] ?? [0.0];
      plantTempValues =
          currentPlantData[plantDates[dataIdx]]?['temperature'] ?? [0.0];
    } else {
      plantwaterValues = [0.0];
      plantTempValues = [0.0];
      selectedDate = noDateSet;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color.fromARGB(255, 255, 245, 235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child:
                  _selectedButton == _SelectedButton.water
                      ? _DailyBarChart(testData: plantwaterValues)
                      : _MonthlyLineChart(
                        date: selectedDate,
                        testData: plantTempValues,
                        showAvg: _showAvg,
                      ),
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
  final List<double> testData;

  const _DailyBarChart({required this.testData});

  // how many times watered or how much water used?
  // decide to show how much water was used in ml

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> myBarData = [];
    double maxVal = 0;
    for (int i = 0; i < testData.length; i++) {
      maxVal = testData[i] > maxVal ? testData[i] : maxVal;

      myBarData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: testData[i],
              color: const Color(0xFF66CC88),
              width: 18,
            ),
          ],
        ),
      );
    }
    double interval = 50;
    double maxY = (maxVal / interval).ceil() * interval;
    return BarChart(
      BarChartData(
        maxY: maxY,
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
        barGroups: [...myBarData],
      ),
      duration: Duration.zero, // disables the animation
    );
  }
}

class _MonthlyLineChart extends StatelessWidget {
  final DateTime date;
  final List<double> testData;
  _MonthlyLineChart({
    required this.date,
    required this.testData,
    required this.showAvg,
  });

  final bool showAvg;
  static const int mondayLimit = 1;
  static const int tuesdayLimit = 3;
  static const int wednesdayLimit = 5;
  static const int thursdayLimit = 7;
  static const int fridayLimit = 9;
  static const int saturdayLimit = 11;
  static const int sundayLimit = 13;
  late final List<FlSpot> lineSpots = [];

  @override
  Widget build(BuildContext context) {
    // insert measured data for temperature
    // hour range
    double minVal1 = 1;
    double maxVal1 = 24;
    // desired day range
    double minVal2 = 0;
    double maxVal2 = 2;
    // find max y value
    double maxValY = 0;

    for (int i = 0; i < testData.length; ++i) {
      // get max val
      maxValY = testData[i] > maxValY ? testData[i] : maxValY;
      if (testData[i] != 0.0) {
        // insert a start value to continue the line in the chart
        if (i == 0) {
          lineSpots.add(FlSpot(0.0, testData[i]));
        }
        double dateHour = date.hour.toDouble();
        double x =
            (minVal2 + (i * 2)) +
            (dateHour - minVal1) *
                ((maxVal2 + (i * 2)) - (minVal2 + (i * 2))) /
                (maxVal1 - minVal1);

        double y = testData[i];

        lineSpots.add(FlSpot(x, y));
      }
    }

    return LineChart(showAvg ? _avgData() : _mainData(maxValY));
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

  LineChartData _mainData(double maxValY) {
    final List<Color> gradientColors = [
      const Color(0xFF66CC88),
      const Color(0xFF66CC88).withAlpha(127),
    ];

    return LineChartData(
      // Enable line touch data
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              // dont show first start value
              if (touchedSpot.x != 0.0) {
                final String value = touchedSpot.y.toStringAsFixed(2);
                return LineTooltipItem(
                  value,
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            }).toList();
          },
        ),
        getTouchedSpotIndicator: (
          LineChartBarData barData,
          List<int> spotIndexes,
        ) {
          return spotIndexes.map((spotIndex) {
            // dont show first start value
            if (spotIndex != 0) {
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
            }
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
            interval: 5,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 14,
      minY: 0,
      maxY: maxValY + 10,
      lineBarsData: [
        LineChartBarData(
          spots: lineSpots,
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

class _PlantCard extends StatefulWidget {
  final List<String> plantKeys;
  final Function(String) onPlantSelected;
  final String selectedPlantKey;

  const _PlantCard({
    required this.plantKeys,
    required this.onPlantSelected,
    required this.selectedPlantKey,
  });

  @override
  State<_PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<_PlantCard> {
  int _displayStartIndex = 0;
  final int _plantIconsPerRow = 3;
  @override
  Widget build(BuildContext context) {
    List<String> plantNames = widget.plantKeys;

    final int end =
        (_displayStartIndex + _plantIconsPerRow > plantNames.length)
            ? plantNames.length
            : _displayStartIndex + _plantIconsPerRow;
    final List<String> plantsToShow = plantNames.sublist(
      _displayStartIndex,
      end,
    );
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color.fromARGB(255, 235, 255, 245),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Visibility(
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  visible: _displayStartIndex > 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    iconSize: 14,
                    onPressed: () {
                      setState(() {
                        _displayStartIndex -= 3;
                        if (_displayStartIndex < 0) {
                          _displayStartIndex = 0;
                        }
                      });
                    },
                  ),
                ),
                const Text(
                  'Planter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Visibility(
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  visible:
                      _displayStartIndex + _plantIconsPerRow <
                      plantNames.length,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    iconSize: 14,
                    onPressed: () {
                      setState(() {
                        _displayStartIndex += _plantIconsPerRow;
                        if (_displayStartIndex >= plantNames.length) {
                          _displayStartIndex =
                              plantNames.length -
                              (plantNames.length % _plantIconsPerRow);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < _plantIconsPerRow; i++)
                  Expanded(
                    child:
                        (i < plantsToShow.length)
                            ? Align(
                              alignment: Alignment.center,
                              child: _buildPlantIconButton(
                                icon: Icons.grass,
                                label: plantsToShow[i],
                                isSelected:
                                    widget.selectedPlantKey == plantsToShow[i],
                                onPressed:
                                    () =>
                                        widget.onPlantSelected(plantsToShow[i]),
                              ),
                            )
                            : const SizedBox(), // empty slot keeps spacing
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Data for ${widget.selectedPlantKey} is shown.',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color:
                isSelected
                    ? Colors.green
                    : Colors.black26, // Green for selected, gray for unselected
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isSelected
                    ? Colors.green
                    : Colors.black54, // Green for selected, gray for unselected
          ),
        ),
      ],
    );
  }
}
