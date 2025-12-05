// services/airline_service.dart
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:voyager/config/voyager_api.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineService {
  Future<List<Airline>> fetchAirlines(
    List<String> originList,
    List<String> destinationList,
  ) async {
    try {
      String originParam = originList.join(',');
      String destinationParam = destinationList.join(',');
      String allParams = 'origin=$originParam&destination=$destinationParam';
      final String url = '$airlinePath?$allParams';
      debugPrint('fetch airlines at $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {voyagerAuthHeader: voyagerAuthToken},
      );
      if (response.statusCode == 200) {
        return await airlinesFromResponse(response.body);
      } else {
        String errorMessage =
            'fetched ${response.statusCode} error from airlines api: ${response.body}';
        debugPrint(errorMessage);
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('ClientException: $e');
      throw Exception('failed to fetch airlines: $e');
    } on Exception catch (e) {
      debugPrint('Exception: $e');
      throw Exception('failed to fetch airlines: $e');
    }
  }

  Future<List<Airline>> airlinesFromResponse(String body) async {
    try {
      final List<dynamic> jsonList = json.decode(body);

      return jsonList.map((item) {
        final String airlineName = item.toString().toLowerCase();
        return Airline.values.firstWhere(
          (airline) => airline.name == airlineName,
          orElse: () => throw Exception('Unknown airline: $airlineName'),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to parse airlines from json: $e');
    }
  }
}
