import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/constants.dart';
import 'package:route_master_mobile_app/models/models.dart';
import 'package:route_master_mobile_app/services/user_service.dart';

class RatingService {
  static Future<Rating> postRating(Rating rating) async {
    final url = Uri.parse('$kDeployedUrl/api/ratings');
    final token = await UserService.getToken();

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(
        <String, dynamic>{
          'value': rating.value,
          'comment': rating.comment,
          'passengerId': rating.passengerId,
          'tripDetailId': rating.tripDetailId
        },
      ),
    );

    if (response.statusCode == 200) {
      return Rating.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create rating');
    }
  }
}
