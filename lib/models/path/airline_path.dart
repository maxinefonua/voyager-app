import 'package:voyager/models/path/route.dart';

class AirlinePath {
  final String airline;
  final double totalDistanceKm;
  final List<Route> routeList;

  AirlinePath({
    required this.airline,
    required this.totalDistanceKm,
    required this.routeList,
  });

  factory AirlinePath.fromJson(Map<String, dynamic> json) {
    return AirlinePath(
      airline: json['airline'],
      totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
      routeList: _parseRouteList(json['routeList']), // Proper parsing
    );
  }

  static List<Route> _parseRouteList(dynamic jsonList) {
    if (jsonList is! List) return [];

    return jsonList
        .whereType<Map<String, dynamic>>()
        .map((item) => Route.fromJson(item))
        .toList();
  }
}
