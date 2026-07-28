import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text("Friends"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.person_add),
        label: const Text("Invite"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [

                    Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: Colors.amber,
                    ),

                    SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Weekly Leaderboard",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Walk more and climb the rankings.",
                          ),

                        ],
                      ),
                    )

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Leaderboard",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),

            const SizedBox(height: 15),

            _friendTile(
              rank: 1,
              name: "Rahul",
              steps: "82,540",
              color: Colors.amber,
            ),

            _friendTile(
              rank: 2,
              name: "Narinder",
              steps: "76,210",
              color: Colors.grey,
              isYou: true,
            ),

            _friendTile(
              rank: 3,
              name: "Aman",
              steps: "71,890",
              color: Colors.brown,
            ),

            _friendTile(
              rank: 4,
              name: "Simran",
              steps: "63,200",
              color: Colors.blue,
            ),

            _friendTile(
              rank: 5,
              name: "Priya",
              steps: "58,110",
              color: Colors.green,
            ),

            const SizedBox(height: 30),

            Card(
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [

                    Icon(
                      Icons.favorite,
                      color: Colors.orange,
                      size: 40,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Walk Together",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Invite your family and friends to complete pilgrimages together and motivate each other every day.",
                      textAlign: TextAlign.center,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  static Widget _friendTile({
    required int rank,
    required String name,
    required String steps,
    required Color color,
    bool isYou = false,
  }) {
    return Card(
      elevation: isYou ? 5 : 2,
      color: isYou ? Colors.orange.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            "$rank",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isYou)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Chip(
                  label: Text("You"),
                ),
              ),
          ],
        ),
        subtitle: Text("$steps steps"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}