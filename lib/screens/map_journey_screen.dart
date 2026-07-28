import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/step_service.dart';

class MapJourneyScreen extends StatefulWidget {
  final String destinationName;
  final String destinationLocation;
  final String destinationEmoji;
  final double latitude;
  final double longitude;


  const MapJourneyScreen({
    super.key,
    required this.destinationName,
    required this.destinationLocation,
    required this.destinationEmoji,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapJourneyScreen> createState() => _MapJourneyScreenState();
}


class _MapJourneyScreenState extends State<MapJourneyScreen> {

  int totalSteps = 0;
  double distanceWalked = 0;
  double progress = 0;
  GoogleMapController? mapController;
  Position? currentPosition;

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  static const LatLng initialPosition =
      LatLng(20.5937, 78.9629);


  @override
 void initState() {
  super.initState();

  loadLocation();

  StepService.startListening(
    (steps){

      setState(() {

        totalSteps = steps;

        // Average human step = 0.75 meters
        distanceWalked = steps * 0.00075;

      });

    },
  );
 }


  Future<void> loadLocation() async {

    try {

      final position = await LocationService.getCurrentLocation();

      print("CURRENT LOCATION:");
      print(position.latitude);
      print(position.longitude);

      currentPosition = position;


      // User Marker
      markers.add(
        Marker(
          markerId: const MarkerId("me"),
          position: LatLng(
            position.latitude,
            position.longitude,
          ),
          infoWindow: const InfoWindow(
            title: "You",
          ),
        ),
      );


      // Destination Marker
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: LatLng(
            widget.latitude,
            widget.longitude,
          ),
          infoWindow: InfoWindow(
            title: widget.destinationName,
            snippet: widget.destinationLocation,
          ),
        ),
      );

      // Yatra Route Line
     polylines.add(
      Polyline(
       polylineId: const PolylineId("yatra_route"),
       points: [
       LatLng(
        position.latitude,
        position.longitude,
        ),
       LatLng(  
        widget.latitude,
        widget.longitude,
        ),
     ],
     width: 5,
       ), 
       );

       print("Polyline count: ${polylines.length}");


      print("Markers count: ${markers.length}");


      setState(() {
      markers;
      polylines;
      });


      // Zoom to show both markers
      if (mapController != null) {

        mapController!.animateCamera(

          CameraUpdate.newLatLngBounds(

            LatLngBounds(

              southwest: LatLng(
                position.latitude < widget.latitude
                    ? position.latitude
                    : widget.latitude,

                position.longitude < widget.longitude
                    ? position.longitude
                    : widget.longitude,
              ),


              northeast: LatLng(
                position.latitude > widget.latitude
                    ? position.latitude
                    : widget.latitude,

                position.longitude > widget.longitude
                    ? position.longitude
                    : widget.longitude,
              ),

            ),

            100,

          ),

        );

      }


    } catch(e) {

      print("Location Error: $e");

    }

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFFFF9F3),


      appBar: AppBar(

        title: const Text(
          "My Yatra",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,

        foregroundColor: Colors.black87,

      ),



      body: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          children: [


            // Destination Card

            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

              ),


              child: Row(

                children: [


                  Text(

                    widget.destinationEmoji,

                    style: const TextStyle(
                      fontSize:45,
                    ),

                  ),


                  const SizedBox(width:15),


                  Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    children: [


                      Text(

                        widget.destinationName,

                        style: const TextStyle(

                          fontSize:22,

                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),


                      Text(

                        widget.destinationLocation,

                        style: const TextStyle(

                          color:
                              Colors.black54,

                        ),

                      ),


                    ],

                  ),


                ],

              ),

            ),



            const SizedBox(height:20),



            // MAP

            Expanded(

              child: ClipRRect(

                borderRadius:
                    BorderRadius.circular(25),


                child: GoogleMap(


                  initialCameraPosition:
                 CameraPosition(
                 target: LatLng(
                  widget.latitude,
                  widget.longitude,
                  ),
                  zoom:12,
                 ),



                  markers: markers,
                  polylines: polylines,


                  myLocationEnabled:true,


                  myLocationButtonEnabled:true,


                  zoomControlsEnabled:true,



                  onMapCreated:(controller){

                 mapController = controller;

                 if (currentPosition != null) {

                 controller.animateCamera(
                 CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                  southwest: LatLng(
                  currentPosition!.latitude < widget.latitude
                 ? currentPosition!.latitude
                 : widget.latitude,

                 currentPosition!.longitude < widget.longitude
                 ? currentPosition!.longitude
                 : widget.longitude,
                 ),

                 northeast: LatLng(
                 currentPosition!.latitude > widget.latitude
                 ? currentPosition!.latitude
                 : widget.latitude,

                 currentPosition!.longitude > widget.longitude
                 ? currentPosition!.longitude
                 : widget.longitude,
                 ),
                 ),
                100,
                ),
                );

                }

                },


                ),

               ),

             ),



            const SizedBox(height:20),



            // Progress Card

            Container(

              padding:
                  const EdgeInsets.all(20),


              decoration:BoxDecoration(

                color:Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

              ),


              child:Column(

                children:[


                  const Text(

                    "Your Progress",

                    style:TextStyle(

                      fontSize:20,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),


                  const SizedBox(height:15),


                  LinearProgressIndicator(

                    value:0.08,

                    minHeight:12,

                    borderRadius:
                        BorderRadius.circular(20),

                  ),


                  const SizedBox(height:18),



                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,


                    children:[


                      _stat(
                      "👣",
                      totalSteps.toString(),
                      "Steps",
                     ),


                     _stat(
                     "📍",
                     "${distanceWalked.toStringAsFixed(2)} km",
                     "Completed",
                     ),


                      _stat("🔥","3 Days","Streak"),


                    ],

                  ),


                ],

              ),

            ),



            const SizedBox(height:15),



            const Text(

              "Every step brings you closer 🙏",

              style:TextStyle(

                fontSize:18,

                fontWeight:
                    FontWeight.bold,

              ),

            ),


          ],

        ),

      ),

    );

  }



  Widget _stat(
      String emoji,
      String value,
      String label,
      ) {

    return Column(

      children:[

        Text(
          emoji,
          style:
              const TextStyle(fontSize:26),
        ),

        Text(
          value,
          style:
              const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
        ),

        Text(label),

      ],

    );

  }

}