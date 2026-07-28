import 'package:flutter/material.dart';

import '../models/journey_model.dart';
import '../services/journey_service.dart';
import 'main_screen.dart';

class CreateJourneyScreen extends StatefulWidget {
  const CreateJourneyScreen({super.key});

  @override
  State<CreateJourneyScreen> createState() => _CreateJourneyScreenState();
}

class _CreateJourneyScreenState extends State<CreateJourneyScreen> {
  String selectedDestination = "Kedarnath";
  String selectedLocation = "Uttarakhand";
  double distance = 2200;

  final TextEditingController sankalpController = TextEditingController(
    text: "I will complete my Yatra with faith and discipline.",
  );

  final destinations = [
    {"name": "Kedarnath", "location": "Uttarakhand", "distance": 2200.0},
    {"name": "Golden Temple", "location": "Amritsar", "distance": 450.0},
    {"name": "Vaishno Devi", "location": "Jammu", "distance": 900.0},
    {"name": "Tirupati", "location": "Andhra Pradesh", "distance": 1800.0},
  ];

  void updateDestination(Map<String, dynamic> item) {
    setState(() {
      selectedDestination = item["name"].toString();
      selectedLocation = item["location"].toString();
      distance = (item["distance"] as num).toDouble();
    });
  }

  Future<void> startJourney() async {
    final journey = JourneyModel(
      startLocation: "Current Location",
      destinationName: selectedDestination,
      destinationLocation: selectedLocation,
      totalDistanceKm: distance,
      startDate: DateTime.now(),
      sankalp: sankalpController.text,
    );

    await JourneyService.createJourney(journey);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text("Create Your Yatra"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Destination 🛕",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...destinations.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item["name"].toString()),
                  subtitle: Text(item["location"].toString()),
                  trailing: selectedDestination == item["name"]
                      ? const Icon(Icons.check_circle, color: Colors.orange)
                      : null,
                  onTap: () => updateDestination(item),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Your Sankalp 🙏",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: sankalpController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: startJourney,
                child: const Text(
                  "Start My Yatra",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}