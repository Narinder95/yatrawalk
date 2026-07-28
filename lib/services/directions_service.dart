import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {

  static const String apiKey = "YOUR_GOOGLE_MAPS_API_KEY";


  static Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {


    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origin.latitude},${origin.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&mode=walking"
        "&key=$apiKey";


    final response = await http.get(
      Uri.parse(url),
    );


    if (response.statusCode == 200) {

      final data = json.decode(response.body);


      if (data["routes"].isNotEmpty) {

        final points =
            data["routes"][0]["overview_polyline"]["points"];


        return decodePolyline(points);

      }

    }


    return [];

  }



  static List<LatLng> decodePolyline(String encoded) {

    List<LatLng> points = [];

    int index = 0;
    int len = encoded.length;

    int lat = 0;
    int lng = 0;


    while (index < len) {

      int b;
      int shift = 0;
      int result = 0;


      do {

        b = encoded.codeUnitAt(index++) - 63;

        result |= (b & 0x1f) << shift;

        shift += 5;

      } while (b >= 0x20);


      int dlat =
          ((result & 1) != 0)
              ? ~(result >> 1)
              : (result >> 1);


      lat += dlat;


      shift = 0;
      result = 0;


      do {

        b = encoded.codeUnitAt(index++) - 63;

        result |= (b & 0x1f) << shift;

        shift += 5;

      } while (b >= 0x20);


      int dlng =
          ((result & 1) != 0)
              ? ~(result >> 1)
              : (result >> 1);


      lng += dlng;


      points.add(
        LatLng(
          lat / 1E5,
          lng / 1E5,
        ),
      );

    }


    return points;

  }

}