import 'package:flutter/material.dart';
import 'package:yatrawalk/screens/map_journey_screen.dart';


class JourneySetupScreen extends StatelessWidget {
  final String destinationName;
  final String destinationLocation;
  final String destinationEmoji;
  final double latitude;
  final double longitude;

  const JourneySetupScreen({
    super.key,
    required this.destinationName,
    required this.destinationLocation,
    required this.destinationEmoji,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFFFF9F3),

      appBar: AppBar(
        title: const Text(
          "Your Yatra Begins",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),


      body: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          children: [

            const SizedBox(height:30),


            Text(
              destinationEmoji,
              style: const TextStyle(
                fontSize:80,
              ),
            ),


            const SizedBox(height:20),


            Text(
              destinationName,
              style: const TextStyle(
                fontSize:32,
                fontWeight:FontWeight.bold,
              ),
            ),


            const SizedBox(height:8),


            Text(
              destinationLocation,
              style: const TextStyle(
                fontSize:18,
                color:Colors.black54,
              ),
            ),


            const SizedBox(height:40),


            Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(20),

                boxShadow:[

                  BoxShadow(
                    color: Colors.black12,
                    blurRadius:10,
                  )

                ],
              ),


              child: Column(

                children:[


                  const Text(
                    "Your Virtual Yatra",
                    style: TextStyle(
                      fontSize:22,
                      fontWeight:FontWeight.bold,
                    ),
                  ),


                  const SizedBox(height:20),


                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceAround,

                    children:[

                      Column(
                        children:[

                          const Icon(
                            Icons.location_on,
                            color:Colors.deepOrange,
                          ),

                          const SizedBox(height:5),

                          const Text(
                            "Starting Point",
                          ),

                          const Text(
                            "Current Location",
                            style: TextStyle(
                              color:Colors.black54,
                            ),
                          ),

                        ],
                      ),


                      const Icon(
                        Icons.arrow_forward,
                      ),


                      Column(
                        children:[

                          const Icon(
                            Icons.temple_hindu,
                            color:Colors.deepOrange,
                          ),

                          const SizedBox(height:5),

                          const Text(
                            "Destination",
                          ),

                          Text(
                            destinationName,
                            style: const TextStyle(
                              color:Colors.black54,
                            ),
                          ),

                        ],
                      ),

                    ],

                  ),

                ],

              ),

            ),


            const SizedBox(height:30),


            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: Colors.orange.shade50,

                borderRadius:
                BorderRadius.circular(18),

              ),

              child: const Column(

                children:[

                  Text(
                    "👣 Every step moves you closer",
                    style: TextStyle(
                      fontSize:18,
                      fontWeight:FontWeight.bold,
                    ),
                  ),

                  SizedBox(height:8),

                  Text(
                    "Your daily walking distance will be converted into progress on your sacred journey.",
                    textAlign:TextAlign.center,
                  ),

                ],

              ),

            ),


            const SizedBox(height: 20),


            SizedBox(

              width:double.infinity,

              height:55,

              child: ElevatedButton(

                onPressed:(){

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MapJourneyScreen(
                                destinationName: destinationName,
                                destinationLocation: destinationLocation,
                                destinationEmoji: destinationEmoji,
                                latitude: latitude,
                                longitude: longitude,
                                ),
                                ),
                                );
                                },

                child: const Text(
                  "Begin My Yatra",
                  style:TextStyle(
                    fontSize:18,
                  ),
                ),

              ),

            ),


          ],

        ),

      ),

    );

  }
}