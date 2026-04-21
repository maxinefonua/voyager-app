import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voyager/config/voyager_api.dart';
import 'package:voyager/models/country/country.dart';
import 'package:voyager/models/voyager/paged_response.dart';

class CountryService {
  final Map<String, Country> _countriesCache = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final countries = await _fetchCountries(); // Now private
      _populateCache(countries);
      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize CountryService: $e');
      debugPrint('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  // Make this private since it's only used internally
  Future<List<Country>> _fetchCountries() async {
    List<Country> countryList = [];
    try {
      final String url = countriesPath;
      int page = 0;
      int size = 300;
      String withPageParams = getPageParams(page, size);
      String fullUrl = '$url?$withPageParams';
      debugPrint('pre first call to countries endpoint');
      http.Response response = await http.get(
        Uri.parse(fullUrl),
        headers: {voyagerAuthHeader: voyagerAuthToken},
      );
      debugPrint(
          'post first call to countries endpoint, response body: ${response.body}');
      while (response.statusCode == 200) {
        PagedResponse<Country> pagedResponse = PagedResponse.fromJson(
          json.decode(response.body),
          Country.fromJson,
        );
        countryList.addAll(pagedResponse.content);
        if (pagedResponse.last) {
          return countryList;
        }
        page++;
        withPageParams = getPageParams(page, size);
        String fullUrl = '$url?$withPageParams';
        response = await http.get(
          Uri.parse(fullUrl),
          headers: {voyagerAuthHeader: voyagerAuthToken},
        );
      }
      debugPrint("failed to fetch all countries");
      throw Exception('Failed to fetch countries: ${response.body}');
    } on http.ClientException catch (e) {
      debugPrint("failed to all all countries");
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

  void _populateCache(List<Country> countries) {
    _countriesCache.clear();
    for (final country in countries) {
      _countriesCache[country.code.toUpperCase()] = country;
    }
  }
}
