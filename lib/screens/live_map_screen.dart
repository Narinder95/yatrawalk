import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveMapScreen extends StatefulWidget {
  final String destinationName;
  final String destinationLocation;
  final String destinationEmoji;

  const LiveMapScreen({
    super.key,
    required this.destinationName,
    required this.destinationLocation,
    required this.destinationEmoji,
  });

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  GoogleMapController? mapController;

  // Temporary location (Bengaluru)
  static const LatLng userLocation = LatLng(12.9716, 77.5946);

  // Temporary destination (Golden Temple)
  static const LatLng destinationLocation = LatLng(31.6200, 74.8765);

  late final Set<Marker> markers;

  @override
  void initState() {
    super.initState();

    markers = {
      const Marker(
        markerId: MarkerId("user"),
        position: userLocation,
        infoWindow: InfoWindow(title: "You"),
      ),
      Marker(
        markerId: const MarkerId("destination"),
        position: destinationLocation,
        infoWindow: InfoWindow(title: widget.destinationName),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Yatra"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: userLocation,
          zoom: 6,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}