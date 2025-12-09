import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voyager/models/airline/airline.dart';

// Read from environment variables
String get baseUrl => dotenv.get('BASE_URL');
String get voyagerAuthToken => dotenv.get('VOYAGER_AUTH_TOKEN');

// Updated URLs using the getter
String get airportsPathWithParams =>
    '$baseUrl/airports?type=civil&airline=${Airline.values.map((airline) => airline.name).join(',')}';

String get nearbyAirportsPath => '$baseUrl/nearby-airports';
String get countriesPath => '$baseUrl/countries';
String get flightsPath => '$baseUrl/flights';
String get pathPath => '$baseUrl/path';
String get airlinePath => '$baseUrl/airlines';

const String voyagerAuthHeader = 'X-Api-Key';
