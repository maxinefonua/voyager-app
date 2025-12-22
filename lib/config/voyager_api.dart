import 'package:voyager/models/airline/airline.dart';

String get baseUrl => "/api";
// String get baseUrl => "http://localhost:8080";
// String get baseUrl => "https://api.voyagerapp.org";
String get voyagerAuthToken => "dev_api_key";

// Updated URLs using the getter
String get airportsPathWithParams =>
    '$baseUrl/airports?type=civil&airline=${Airline.values.map((airline) => airline.name).join(',')}';

String get nearbyAirportsPath => '$baseUrl/nearby-airports';
String get countriesPath => '$baseUrl/countries';
String get flightsPath => '$baseUrl/flights';
String get pathPath => '$baseUrl/path';
String get airlinePath => '$baseUrl/airlines';

const String voyagerAuthHeader = 'X-Api-Key';
