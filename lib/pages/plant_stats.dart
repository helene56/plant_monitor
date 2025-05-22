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
              color: Color(0xFFE3EEEC),
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
                      color: const Color.fromARGB(
                        255,
                        105,
                        190,
                        240,
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            const Color.fromARGB(
                              109,
                              105,
                              190,
                              240,
                            ),
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color:
                            const Color.fromARGB(
                              255,
                              105,
                              190,
                              240,
                            ),
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
                      color: Colors.amber,
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            const Color.fromARGB(
                              109,
                              240,
                              229,
                              105,
                            ),
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color:
                            const Color.fromARGB(
                              255,
                              240,
                              229,
                              105,
                            ),
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
                      color: const Color.fromARGB(
                        255,
                        33,
                        150,
                        243,
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            const Color.fromARGB(
                              109,
                              33,
                              150,
                              243,
                            ),
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color:
                            const Color.fromARGB(
                              255,
                              33,
                              150,
                              243,
                            ),
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
                      color: const Color.fromARGB(
                        255,
                        255,
                        112,
                        67,
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            const Color.fromARGB(
                              109,
                              255,
                              112,
                              67,
                            ),
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color:
                            const Color.fromARGB(
                              255,
                              255,
                              112,
                              67,
                            ),
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
                      color: const Color.fromARGB(
                        255,
                        141,
                        110,
                        99,
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 260,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            const Color.fromARGB(
                              109,
                              141,
                              110,
                              99,
                            ),
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        color:
                            const Color.fromARGB(
                              255,
                              141,
                              110,
                              99,
                            ),
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
