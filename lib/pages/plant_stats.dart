import 'package:flutter/material.dart';

class MyPlantStat extends StatelessWidget {
  final int plantId;
  const MyPlantStat({
    super.key,
    required this.plantId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              SizedBox(
                width: 300,
                child: Image.asset(
                  './images/plant_test.png',
                ),
              ),
              Text(
                'id: $plantId',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color.fromARGB(
                255,
                255,
                245,
                235,
              ),
              borderRadius: BorderRadius.circular(
                8,
              ),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            width: 350,
            height: 350,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                Text('Vand'),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: Color.fromARGB(
                        255,
                        120,
                        180,
                        220,
                      ), // Match Water bar
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            Color.fromARGB(
                              85,
                              120,
                              180,
                              220,
                            ), // Water bg
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color: Color.fromARGB(
                          255,
                          120,
                          180,
                          220,
                        ), // Water bar
                        minHeight: 20,
                        value: 0.5,
                      ),
                    ),
                  ],
                ),
                Text('Sollys'),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      color: Color.fromARGB(
                        255,
                        255,
                        213,
                        79,
                      ), // Match Sunlight bar
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            Color.fromARGB(
                              85,
                              255,
                              213,
                              79,
                            ), // Sunlight bg
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color: Color.fromARGB(
                          255,
                          255,
                          213,
                          79,
                        ), // Sunlight bar
                        minHeight: 20,
                        value: 0.5,
                      ),
                    ),
                  ],
                ),
                Text('Fugt'),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.foggy,
                      color: Color.fromARGB(
                        255,
                        139,
                        193,
                        183,
                      ), // Match Moisture bar
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            Color.fromARGB(
                              85,
                              139,
                              193,
                              183,
                            ), // Moisture bg
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color: Color.fromARGB(
                          255,
                          139,
                          193,
                          183,
                        ), // Moisture bar
                        minHeight: 20,
                        value: 0.5,
                      ),
                    ),
                  ],
                ),
                Text('Luft temperatur'),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.thermostat,
                      color: Color.fromARGB(
                        255,
                        255,
                        183,
                        77,
                      ), // Match Air temp bar
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            Color.fromARGB(
                              85,
                              255,
                              183,
                              77,
                            ), // Air temp bg
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color: Color.fromARGB(
                          255,
                          255,
                          183,
                          77,
                        ), // Air temp bar
                        minHeight: 20,
                        value: 0.5,
                      ),
                    ),
                  ],
                ),
                Text('Jord temperatur'),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.thermostat,
                      color: Color.fromARGB(
                        255,
                        188,
                        170,
                        164,
                      ), // Match Earth temp bar
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            Color.fromARGB(
                              85,
                              188,
                              170,
                              164,
                            ), // Earth temp bg
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color: Color.fromARGB(
                          255,
                          188,
                          170,
                          164,
                        ), // Earth temp bar
                        minHeight: 20,
                        value: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
