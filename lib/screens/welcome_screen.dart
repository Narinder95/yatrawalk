import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatelessWidget {

  const WelcomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.directions_walk,
                size: 90,
                color: Colors.orange,
              ),


              const SizedBox(height: 25),


              const Text(
                "Welcome to DigiTeerth 🙏",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 15),


              const Text(
                "Complete your spiritual journey one step at a time.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                ),
              ),


              const SizedBox(height: 40),


              ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),

                onPressed: () async {

                  await UserService.createJourney();


                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(),
                    ),
                  );

                },


                child: const Text(
                  "Start My Yatra",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

              )

            ],
          ),
        ),
      ),
    );
  }
}