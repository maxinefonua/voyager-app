import 'package:voyager/models/airline/airline.dart';

const String _baseUrl = 'http://localhost:8081';
String airportsPathWithParams =
    '$_baseUrl/airports?type=civil&airline=${Airline.values.map((airline) => airline.name).join(',')}';
const String nearbyAirportsPath = '$_baseUrl/nearby-airports';
const String countriesPath = '$_baseUrl/countries';
const String flightsPath = '$_baseUrl/flights';
const String pathPath = '$_baseUrl/path';
const String airlinePath = '$_baseUrl/airlines';

const String voyagerAuthToken = 'admin_api_key';
const String voyagerAuthHeader = 'X-Api-Key';
