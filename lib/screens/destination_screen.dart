import 'package:flutter/material.dart';
import 'journey_setup_screen.dart';
import '../services/storage_service.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {

  String selectedCategory = "All";
  String searchText = "";

  Destination? selectedDestination;

  final List<Destination> destinations = [
    Destination(
      name: "Golden Temple",
      location: "Amritsar, Punjab",
      category: "Gurudwara",
      emoji: "🛕",
      latitude: 31.6200,
      longitude: 74.8765,
    ),
    Destination(
      name: "Kedarnath",
      location: "Uttarakhand",
      category: "Temple",
      emoji: "🕉",
      latitude: 30.7352,
      longitude: 79.0669,
    ),
    Destination(
      name: "Vaishno Devi",
      location: "Jammu",
      category: "Temple",
      emoji: "🛕",
      latitude: 33.0307,
      longitude: 74.9490
    ),
    Destination(
      name: "Tirupati Balaji",
      location: "Andhra Pradesh",
      category: "Temple",
      emoji: "🛕",
      latitude: 13.6833,
      longitude: 79.3470,
    ),
    Destination(
      name: "Bodh Gaya",
      location: "Bihar",
      category: "Buddhist",
      emoji: "☸", 
      latitude: 24.6950,
      longitude: 84.9913,
    ),
    Destination(
      name: "Ajmer Sharif",
      location: "Rajasthan",
      category: "Dargah",
      emoji: "☪",
      latitude: 26.4579,
      longitude: 74.6283,
    ),
    Destination(
      name: "Shirdi Sai Baba",
      location: "Maharashtra",
      category: "Temple",
      emoji: "⛩",
      latitude: 19.7666,
      longitude: 74.4774,
    ),
  ];


  @override
  Widget build(BuildContext context) {

    final filteredDestinations = destinations.where((destination) {

      final matchesSearch = destination.name
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchesCategory =
          selectedCategory == "All" ||
          destination.category == selectedCategory;

      return matchesSearch && matchesCategory;

    }).toList();


    return Scaffold(

      backgroundColor: const Color(0xFFFFF9F3),

      appBar: AppBar(
        title: const Text(
          "Choose Your Sacred Destination",
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

            // Search bar
            TextField(

              onChanged: (value){
                setState(() {
                  searchText = value;
                });
              },

              decoration: InputDecoration(

                hintText: "Search destination",

                prefixIcon: const Icon(Icons.search),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),

              ),
            ),


            const SizedBox(height:20),


            // Category chips
            SizedBox(
              height:45,

              child: ListView(

                scrollDirection: Axis.horizontal,

                children: [

                  "All",
                  "Temple",
                  "Gurudwara",
                  "Buddhist",
                  "Dargah"

                ].map((category){

                  return Padding(

                    padding: const EdgeInsets.only(right:10),

                    child: ChoiceChip(

                      label: Text(category),

                      selected:
                      selectedCategory == category,

                      onSelected: (_) {

                        setState(() {
                          selectedCategory = category;
                        });

                      },

                    ),

                  );

                }).toList(),

              ),
            ),


            const SizedBox(height:20),


            // Destination list
            Expanded(

              child: ListView.builder(

                itemCount: filteredDestinations.length,

                itemBuilder: (context,index){

                  final destination =
                  filteredDestinations[index];


                  final isSelected =
                  selectedDestination == destination;


                  return GestureDetector(

                    onTap: (){

                      setState(() {
                        selectedDestination = destination;
                      });

                    },


                    child: Container(

                      margin:
                      const EdgeInsets.only(bottom:15),

                      padding:
                      const EdgeInsets.all(18),


                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(20),

                        border: Border.all(

                          color: isSelected
                              ? Colors.deepOrange
                              : Colors.transparent,

                          width:2,

                        ),

                        boxShadow:[

                          BoxShadow(
                            color: Colors.black12,
                            blurRadius:8,
                          )

                        ],

                      ),


                      child: Row(

                        children:[


                          Text(
                            destination.emoji,
                            style:
                            const TextStyle(
                              fontSize:40,
                            ),
                          ),


                          const SizedBox(width:15),


                          Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children:[

                              Text(

                                destination.name,

                                style:
                                const TextStyle(
                                  fontSize:20,
                                  fontWeight:
                                  FontWeight.bold,
                                ),

                              ),


                              const SizedBox(height:5),


                              Text(
                                destination.location,
                                style:
                                const TextStyle(
                                  color:
                                  Colors.black54,
                                ),
                              ),

                            ],

                          )

                        ],

                      ),

                    ),

                  );

                },

              ),

            ),


            // Continue button
            SizedBox(

              width:double.infinity,

              height:55,

              child: ElevatedButton(

                onPressed: selectedDestination == null
                ? null
                : () async { 
                     await StorageService.saveJourney(
                        destinationName: selectedDestination!.name,
                        destinationLocation: selectedDestination!.location,
                        destinationEmoji: selectedDestination!.emoji,
                        latitude: 31.6200,
                        longitude: 74.8765,
                        );
                        print("SAVE SUCCESS");
                        if (!context.mounted) return;

                     
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => JourneySetupScreen(
                                destinationName: selectedDestination!.name,
                                destinationLocation: selectedDestination!.location,
                                destinationEmoji: selectedDestination!.emoji,
                                latitude: 31.6200,
                                longitude: 74.8765,
                                ),
                                ),
                                );
                                },


                child:
                const Text(
                  "Start Your Yatra",
                  style:
                  TextStyle(fontSize:18),
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}
class Destination {
  final String name;
  final String location;
  final String category;
  final String emoji;
  final double latitude;
  final double longitude;

  Destination({
    required this.name,
    required this.location,
    required this.category,
    required this.emoji,
    required this.latitude,
    required this.longitude,
  });
}
