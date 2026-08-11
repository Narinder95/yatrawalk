import 'package:flutter/material.dart';
import 'journey_setup_screen.dart';
import '../models/journey_model.dart';
import '../services/journey_service.dart';
import '../services/step_service.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {

  String selectedCategory = "All";
  String searchText = "";

  Destination? selectedDestination;

  // If the user already has an active (unfinished) Yatra, we ask for
  // confirmation before letting them start a new one, since starting a new
  // Yatra archives the current one's progress.
  JourneyModel? _existingActiveJourney;

  @override
  void initState() {
    super.initState();
    _loadExistingJourney();
  }

  Future<void> _loadExistingJourney() async {
    final journey = await JourneyService.getActiveJourney();
    if (!mounted) return;
    setState(() {
      _existingActiveJourney = (journey != null && !journey.completed)
          ? journey
          : null;
    });
  }

  Future<bool> _confirmReplaceActiveJourneyIfNeeded() async {
    final active = _existingActiveJourney;
    if (active == null) return true;

    final progressPercent = (active.progressPercentage * 100).toStringAsFixed(0);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Start a new Yatra?"),
        content: Text(
          "You already have an active Yatra to ${active.destinationName} "
          "($progressPercent% complete). Starting a new Yatra will archive "
          "your current one - its progress is kept in your history, but it "
          "will no longer be tracked as active.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Start New Yatra"),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Lets the user set their own Sankalp (manifestation wish/pledge) for
  /// this Yatra, instead of a hardcoded generic pledge. Returns null if
  /// the user cancels out of starting the Yatra entirely.
  Future<String?> _askForSankalp() async {
    final controller = TextEditingController(
      text: "I will complete my Yatra with faith and discipline.",
    );

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("🙏 Set your Sankalp"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "A Sankalp is a wish or intention you carry with you "
              "through this Yatra - you can revisit and renew it daily.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Write your Sankalp...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(
                dialogContext,
                text.isNotEmpty
                    ? text
                    : "I will complete my Yatra with faith and discipline.",
              );
            },
            child: const Text("Begin Yatra"),
          ),
        ],
      ),
    );
  }

  final List<Destination> destinations = [
    Destination(
      name: "Golden Temple",
      location: "Amritsar, Punjab",
      category: "Gurudwara",
      emoji: "🛕",
      latitude: 31.6200,
      longitude: 74.8765,
      distanceKm: 450,
      backgroundImage: 'assets/images/destination-backgrounds/golden_temple.png',
    ),
    Destination(
      name: "Kedarnath",
      location: "Uttarakhand",
      category: "Temple",
      emoji: "🕉",
      latitude: 30.7352,
      longitude: 79.0669,
      distanceKm: 2200,
      backgroundImage: 'assets/images/destination-backgrounds/kedarnath.png',
    ),
    Destination(
      name: "Vaishno Devi",
      location: "Jammu",
      category: "Temple",
      emoji: "🛕",
      latitude: 33.0307,
      longitude: 74.9490,
      distanceKm: 900,
      backgroundImage: 'assets/images/destination-backgrounds/vaishno_devi.png',
    ),
    Destination(
      name: "Tirupati Balaji",
      location: "Andhra Pradesh",
      category: "Temple",
      emoji: "🛕",
      latitude: 13.6833,
      longitude: 79.3470,
      distanceKm: 1800,
      backgroundImage: 'assets/images/destination-backgrounds/tirupati_balaji.png',
    ),
    Destination(
      name: "Bodh Gaya",
      location: "Bihar",
      category: "Buddhist",
      emoji: "☸",
      latitude: 24.6950,
      longitude: 84.9913,
      distanceKm: 1200,
      backgroundImage: 'assets/images/destination-backgrounds/bodh_gaya.png',
    ),
    Destination(
      name: "Ajmer Sharif",
      location: "Rajasthan",
      category: "Dargah",
      emoji: "☪",
      latitude: 26.4579,
      longitude: 74.6283,
      distanceKm: 700,
      backgroundImage: 'assets/images/destination-backgrounds/ajmer_sharif.png',
    ),
    Destination(
      name: "Shirdi Sai Baba",
      location: "Maharashtra",
      category: "Temple",
      emoji: "⛩",
      latitude: 19.7666,
      longitude: 74.4774,
      distanceKm: 1400,
      backgroundImage: 'assets/images/destination-backgrounds/shirdi_sai_baba.png',
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
                     final destination = selectedDestination!;

                     final canProceed =
                         await _confirmReplaceActiveJourneyIfNeeded();
                     if (!canProceed) return;
                     if (!context.mounted) return;

                     final sankalp = await _askForSankalp();
                     if (sankalp == null) return; // user backed out
                     if (!context.mounted) return;

                     // Archive whatever was active before, so there's only
                     // ever one active Yatra at a time.
                     final previous = _existingActiveJourney;
                     if (previous != null) {
                       await JourneyService.updateJourney(
                         previous.copyWith(completed: true),
                       );
                     }

                     final journey = JourneyModel(
                       startLocation: "Current Location",
                       destinationName: destination.name,
                       destinationLocation: destination.location,
                       destinationEmoji: destination.emoji,
                       backgroundImage: destination.backgroundImage,
                       latitude: destination.latitude,
                       longitude: destination.longitude,
                       totalDistanceKm: destination.distanceKm,
                       startDate: DateTime.now(),
                       // Steps taken before this moment don't count towards
                       // this Yatra's progress.
                       startStepsSnapshot: StepService().totalSteps,
                       sankalp: sankalp,
                     );

                     await JourneyService.createJourney(journey);
                     if (!context.mounted) return;

                     Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => JourneySetupScreen(
                                destinationName: destination.name,
                                destinationLocation: destination.location,
                                destinationEmoji: destination.emoji,
                                latitude: destination.latitude,
                                longitude: destination.longitude,
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
  final double distanceKm;
  final String backgroundImage;

  Destination({
    required this.name,
    required this.location,
    required this.category,
    required this.emoji,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.backgroundImage,
  });
}
