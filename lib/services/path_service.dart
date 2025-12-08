// services/path_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voyager/config/voyager_api.dart';
import 'package:voyager/models/path/path_detailed.dart';
import 'package:voyager/models/path/search_response.dart';
import 'package:voyager/models/voyager/path_request.dart';
import 'package:voyager/services/timezone/timezone_service.dart'
    show TimezoneService;

class PathService {
  final _pathCache = <PathRequest, SearchResponse>{};
  // Private constructor
  final TimezoneService timezoneService;
  PathService._internal({required this.timezoneService});

  // Static instance
  static PathService? _instance;

  // Factory constructor returns the same instance
  factory PathService() {
    if (_instance == null) {
      throw Exception('PathService must be initialized first with init()');
    }
    return _instance!;
  }
  // Initialize method
  static void init(TimezoneService timezoneService) {
    _instance = PathService._internal(timezoneService: timezoneService);
  }

  Future<SearchResponse> fetchPaths(PathRequest pathRequest) async {
    SearchResponse? cachedResponse = _pathCache[pathRequest];
    if (cachedResponse == null) {
      final searchResponse = await _fetchFirstPaths(pathRequest);
      _pathCache[pathRequest] = searchResponse;
      return searchResponse;
    } else {
      if (cachedResponse.size < 10) {
        cachedResponse = await _fetchFirstPaths(pathRequest);
        _pathCache[pathRequest] = cachedResponse;
      }
      final firstPage = SearchResponse(
        content: cachedResponse.content.sublist(
          0,
          min(10, cachedResponse.content.length),
        ),
        status: cachedResponse.status,
        hasMore: cachedResponse.hasMore,
        totalFound: cachedResponse.totalFound,
        size: min(10, cachedResponse.content.length),
      );
      return firstPage;
    }
  }

  Future<SearchResponse> fetchNextPage(
    PathRequest originalRequest,
    int skip,
  ) async {
    final cached = _pathCache[originalRequest];
    if (cached == null) {
      final error =
          'illegal state, fetchNextBatch called without cached firstPaths';
      debugPrint('Illegal state: $error');
      throw StateError(error);
    }
    if (cached.size - skip >= 10) {
      List<PathDetailed> pagedContent = cached.content.sublist(
        0,
        (skip + min(10, cached.content.length - skip)),
      );
      final nextPage = SearchResponse(
        content: pagedContent,
        status: cached.status,
        hasMore: cached.hasMore,
        totalFound: cached.totalFound,
        size: pagedContent.length,
      );
      return nextPage;
    }

    SearchResponse freshBatch = await _fetchNextPaths(originalRequest, skip);
    int retries = 0;
    while (freshBatch.content.isEmpty && freshBatch.hasMore && retries++ < 2) {
      if (freshBatch.status == 'FAILED') {
        debugPrint('fetched batch with FAILED status after $retries retries');
        break;
      }
      if (freshBatch.content.isNotEmpty) {
        break;
      }
      final delayMs = 100 * (1 << (retries - 1)).clamp(100, 5000);
      debugPrint('attempting retry $retries after $delayMs ms');
      await Future.delayed(Duration(milliseconds: delayMs));
      freshBatch = await _fetchNextPaths(originalRequest, skip);
    }
    List<PathDetailed> combined = [...cached.content, ...freshBatch.content];
    final withNextBatch = SearchResponse(
      content: combined,
      status: freshBatch.status,
      hasMore: freshBatch.hasMore,
      totalFound: freshBatch.totalFound,
      size: cached.size + freshBatch.size,
    );
    _pathCache[originalRequest] = withNextBatch;
    List<PathDetailed> pagedContent = withNextBatch.content.sublist(
      0,
      (skip + min(10, withNextBatch.content.length - skip)),
    );
    final nextPage = SearchResponse(
      content: pagedContent,
      status: withNextBatch.status,
      hasMore: withNextBatch.hasMore,
      totalFound: withNextBatch.totalFound,
      size: pagedContent.length,
    );
    return nextPage;
  }

  String _buildParams(PathRequest pathRequest) {
    String startParam = timezoneService.formatTimeForAPI(
      pathRequest.startTime,
      pathRequest.timezoneId,
    );
    String originParam = pathRequest.originList.join(',');
    String destinationParam = pathRequest.destinationList.join(',');
    String zoneId = pathRequest.timezoneId;
    String allParams =
        'origin=$originParam&destination=$destinationParam&start=$startParam&zoneId=$zoneId';
    if (pathRequest.airline != null) {
      allParams =
          '$allParams&airline=${pathRequest.airline!.name.toUpperCase()}';
    }
    return allParams;
  }

  Future<SearchResponse> _fetchFirstPaths(PathRequest pathRequest) async {
    try {
      String allParams = _buildParams(pathRequest);
      final String url = '$pathPath?$allParams';
      final response = await http.get(
        Uri.parse(url),
        headers: {voyagerAuthHeader: voyagerAuthToken},
      );
      if (response.statusCode == 200) {
        final searchResponse = await _searchResponseFromJson(response.body);
        if (searchResponse.content.isEmpty) {
          searchResponse.content.addAll(
            _buildoutNoFlights(
              pathRequest.originList,
              pathRequest.destinationList,
            ),
          );
        }
        return searchResponse;
      } else {
        String errorMessage =
            'fetched ${response.statusCode} error from flights api: ${response.body}';
        debugPrint(errorMessage);
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('ClientException: $e');
      throw Exception('failed to fetch paths: $e');
    } on Exception catch (e) {
      debugPrint('Exception: $e');
      throw Exception('failed to fetch paths: $e');
    }
  }

  Future<SearchResponse> _fetchNextPaths(
    PathRequest pathRequest,
    int skip,
  ) async {
    try {
      String allParams = _buildParams(pathRequest);
      allParams = '$allParams&skip=$skip';
      final String url = '$pathPath?$allParams';
      final response = await http.get(
        Uri.parse(url),
        headers: {voyagerAuthHeader: voyagerAuthToken},
      );
      if (response.statusCode == 200) {
        final searchResponse = await _searchResponseFromJson(response.body);
        return searchResponse;
      } else {
        String errorMessage =
            'fetched ${response.statusCode} error from flights api: ${response.body}';
        debugPrint(errorMessage);
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('ClientException: $e');
      throw Exception('failed to fetch paths: $e');
    } on Exception catch (e) {
      debugPrint('Exception: $e');
      throw Exception('failed to fetch paths: $e');
    }
  }

  Future<SearchResponse> _searchResponseFromJson(String body) async {
    try {
      final Map<String, dynamic> jsonMap = json.decode(body);
      final SearchResponse searchResponse = SearchResponse.fromJson(jsonMap);
      return searchResponse;
    } catch (e) {
      throw Exception('Failed to parse searchResponse from json: $e');
    }
  }

  List<PathDetailed> _buildoutNoFlights(
    List<String> originList,
    List<String> destinationList,
  ) {
    return originList
        .expand(
          (origin) => destinationList
              .map(
                (destination) => PathDetailed(
                  flightPathList: List.empty(),
                  iataList: [origin, destination],
                  pathOrigin: origin,
                  pathDestination: destination,
                  totalDistanceKm: 0,
                ),
              )
              .toList(),
        )
        .toList();
  }
}
