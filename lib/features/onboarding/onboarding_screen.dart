import 'package:flutter/material.dart';

import '../../screens/home_screen.dart';
import '../../services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();

  int _currentPage = 0;
  static const int _totalPages = 5;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    debugPrint("Finish button pressed");

    await _onboardingService.completeOnboarding();

    debugPrint("Onboarding completed");

    if (!mounted) return;

    debugPrint("Navigating to HomeScreen");

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  debugPrint("Current page: $index");
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildHowItWorksPage(),
                  _buildPermissionsPage(),
                  _buildDestinationPage(),
                  _buildCreatingJourneyPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _page(
      icon: Icons.directions_walk,
      title: "Welcome to DigiTeerth",
      subtitle: "Every step you take becomes part of an unforgettable journey.",
    );
  }

  Widget _buildHowItWorksPage() {
    return _page(
      icon: Icons.route,
      title: "Your Steps Power Your Journey",
      subtitle:
          "Your daily steps are automatically added to your selected journey. Just keep walking!",
    );
  }

  Widget _buildPermissionsPage() {
    return _page(
      icon: Icons.security,
      title: "Permissions",
      subtitle:
          "We'll ask for Activity and Location permissions so DigiTeerth can count your steps and track your journey.",
    );
  }

  Widget _buildDestinationPage() {
    return _page(
      icon: Icons.location_on,
      title: "Choose Your Destination",
      subtitle:
          "Select the place you'd like to walk towards. You can change it later.",
    );
  }

  Widget _buildCreatingJourneyPage() {
    return _page(
      icon: Icons.flag,
      title: "Creating Your Journey",
      subtitle: "We're preparing your profile and assigning your DigiTeerth ID.",
      isLast: true,
    );
  }

  Widget _page({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Colors.orange,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLast ? _finishOnboarding : _nextPage,
              child: Text(
                isLast ? "Finish" : "Continue",
              ),
            ),
          ),
        ],
      ),
    );
  }
}