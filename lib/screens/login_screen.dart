import 'package:flutter/material.dart';
import 'destination_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F3),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [

              const Spacer(),

              Image.asset(
                'assets/images/logo.png',
                width: 120,
              ),

              const SizedBox(height: 24),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Continue your spiritual journey",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),

              const Spacer(),


              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(

                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DestinationScreen(),
                      ),
                    );

                  },

                  icon: const Icon(Icons.login),

                  label: const Text(
                    "Continue with Google",
                  ),
                ),
              ),


              const SizedBox(height:16),


              SizedBox(
                width: double.infinity,
                height:55,

                child: OutlinedButton.icon(

                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DestinationScreen(),
                      ),
                    );

                  },

                  icon: const Icon(Icons.phone),

                  label: const Text(
                    "Continue with Phone",
                  ),
                ),
              ),


              const SizedBox(height:16),


              TextButton(

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DestinationScreen(),
                    ),
                  );

                },

                child: const Text(
                  "Skip for now",
                ),
              ),


              const SizedBox(height:30),

            ],
          ),
        ),
      ),
    );
  }
}