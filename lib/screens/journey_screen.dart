import 'package:flutter/material.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text("My Journey"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Journey Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    const Icon(
                      Icons.temple_hindu,
                      size: 60,
                      color: Colors.orange,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Golden Temple",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Icon(Icons.arrow_downward),

                    const Text(
                      "Kedarnath",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    LinearProgressIndicator(
                      value: 0.18,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.orange,
                      backgroundColor: Colors.orange.shade100,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "18% Journey Completed",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Statistics
            Row(
              children: [

                Expanded(
                  child: _statCard(
                    Icons.route,
                    "Distance",
                    "52 km",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    Icons.flag,
                    "Remaining",
                    "238 km",
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    Icons.calendar_today,
                    "Days",
                    "8",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    Icons.local_fire_department,
                    "Streak",
                    "8 Days",
                  ),
                ),

              ],
            ),

            const SizedBox(height: 25),

            /// Sankalp
            Card(
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "🙏 My Sankalp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "I will walk every day until I complete this sacred journey.",
                      style: TextStyle(fontSize: 17),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// Timeline
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Journey Milestones",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 15),

            _timelineTile(
              Icons.check_circle,
              Colors.green,
              "Journey Started",
              "Completed",
            ),

            _timelineTile(
              Icons.check_circle,
              Colors.green,
              "25 km Walked",
              "Completed",
            ),

            _timelineTile(
              Icons.radio_button_unchecked,
              Colors.grey,
              "100 km Milestone",
              "Upcoming",
            ),

            _timelineTile(
              Icons.radio_button_unchecked,
              Colors.grey,
              "Destination Reached",
              "Pending",
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.favorite),
                label: const Text(
                  "Renew Sankalp",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  Widget _statCard(
      IconData icon,
      String title,
      String value,
      ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: Column(
          children: [

            Icon(
              icon,
              color: Colors.orange,
              size: 34,
            ),

            const SizedBox(height: 8),

            Text(title),

            const SizedBox(height: 6),

            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _timelineTile(
      IconData icon,
      Color color,
      String title,
      String subtitle,
      ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}