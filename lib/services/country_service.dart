import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voyager/config/voyager_api.dart';
import 'package:voyager/models/country/country.dart';

class CountryService {
  final Map<String, Country> _countriesCache = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final countries = await _fetchCountries(); // Now private
      _populateCache(countries);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize CountryService: $e');
      rethrow;
    }
  }

  // Make this private since it's only used internally
  Future<List<Country>> _fetchCountries() async {
    try {
      final String url = countriesPath;
      final response = await http.get(
        Uri.parse(url),
        headers: {voyagerAuthHeader: voyagerAuthToken},
      );
      if (response.statusCode == 200) {
        return _countryFromJson(response.body); // Also make private
      } else {
        throw Exception('Failed to load countries: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Failed to load countries: $e');
    }
  }

  // Public API - only these should be used externally
  Country? getCountry(String countryCode) {
    if (!_isInitialized) {
      throw StateError('CountryService must be initialized first');
    }
    return _countriesCache[countryCode.toUpperCase()];
  }

  List<Country> getAllCountries() {
    if (!_isInitialized) {
      throw StateError('CountryService must be initialized first');
    }
    return _countriesCache.values.toList();
  }

  bool get isInitialized => _isInitialized;

  // Make JSON parsing private too
  Future<List<Country>> _countryFromJson(String body) async {
    final List<dynamic> jsonList = json.decode(body);
    return jsonList.map((jsonItem) => Country.fromJson(jsonItem)).toList();
  }

  void _populateCache(List<Country> countries) {
    _countriesCache.clear();
    for (final country in countries) {
      _countriesCache[country.code.toUpperCase()] = country;
    }
  }
}
