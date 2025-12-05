import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voyager/config/voyager_api.dart';
import 'package:voyager/models/airline/airline.dart';
import 'package:voyager/models/airport/airport.dart';

class AirportCache {
  final Map<String, Airport> _airportsCache = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final airports = await _fetchAirports(); // Now private
      _populateCache(airports);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize AirportsCache: $e');
      rethrow;
    }
  }

  Future<List<Airport>> fetchNearbyAirports(
    String iata,
    Airline? airline,
  ) async {
    try {
      String allParams = 'type=civil&limit=11&iata=$iata';
      if (airline != null) {
        allParams = '$allParams&airline=${airline.name}';
      } else {
        allParams =
            '$allParams&airline=${Airline.values.map((value) => value.name).join(',')}';
      }
      final String url = '$nearbyAirportsPath?$allParams';
      debugPrint('fetch nearby airports at $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {voyagerAuthHeader: voyagerAuthToken},
      );
      if (response.statusCode == 200) {
        return _airportFromJson(response.body); // Also make private
      } else {
        throw Exception('failed to fetch nearby airports: ${response.body}');
      }
    } on Exception catch (e) {
      debugPrint('failed to fetch nearby airports: ${e.toString()}');
      rethrow;
    }
  }

  // Make this private since it's only used internally
  Future<List<Airport>> _fetchAirports() async {
    try {
      final String url = airportsPathWithParams;
      final response = await http.get(
        Uri.parse(url),
        headers: {voyagerAuthHeader: voyagerAuthToken},
      );
      if (response.statusCode == 200) {
        return _airportFromJson(response.body); // Also make private
      } else {
        throw Exception('Failed to fetch airports: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Failed to load airports: $e');
    }
  }

  Airport? getAirport(String airportCode) {
    if (!_isInitialized) {
      throw StateError('AirportsCache must be initialized first');
    }
    return _airportsCache[airportCode.toUpperCase()];
  }

  List<Airport> getAllAirports() {
    if (!_isInitialized) {
      throw StateError('AirportsCache must be initialized first');
    }
    debugPrint('Cache returning ${_airportsCache.length} airports'); // Debug
    return _airportsCache.values.toList();
  }

  bool get isInitialized => _isInitialized;

  Future<List<Airport>> _airportFromJson(String body) async {
    final List<dynamic> jsonList = json.decode(body);
    return jsonList.map((jsonItem) => Airport.fromJson(jsonItem)).toList();
  }

  void _populateCache(List<Airport> airports) {
    _airportsCache.clear();
    for (final airport in airports) {
      _airportsCache[airport.iata.toUpperCase()] = airport;
    }
  }
}
