import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  final String apiKey;

  DirectionsService(this.apiKey);

  Future<dynamic> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final uri =
          Uri.parse('$_baseUrl?origin=${origin.latitude},${origin.longitude}'
              '&destination=${destination.latitude},${destination.longitude}'
              '&mode=transit'
              '&transit_mode=bus'
              '&alternatives=true'
              '&key=$apiKey'
              '&language=es');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load directions');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
