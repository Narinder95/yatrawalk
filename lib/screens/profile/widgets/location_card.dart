import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final VoidCallback onTap;
  final String location;

  const LocationCard({
    super.key,
    required this.onTap,
    this.location = "Tap to choose your base location",
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.location_on,
          color: Colors.green,
        ),
        title: const Text("Base Location"),
        subtitle: Text(location),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}