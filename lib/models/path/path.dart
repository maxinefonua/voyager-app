import 'package:voyager/models/path/route.dart';

class Path {
  final List<Route> routeList;
  final double totalDistanceKm;

  Path({required this.routeList, required this.totalDistanceKm});

  String get displayText {
    if (routeList.isEmpty) return 'No routes';
    String joiner = ' → ';
    return '${routeList.first.origin}$joiner${routeList.map((route) => route.destination).join(joiner)}';
  }

  bool get isNonStop {
    return routeList.length == 1;
  }

  String get stops {
    switch (routeList.length) {
      case 1:
        return 'Direct';
      case 2:
        return '1stop';
      default:
        return '2+stop';
    }
  }

  factory Path.fromJson(Map<String, dynamic> json) {
    return Path(
      routeList: (json['routeList'] as List)
          .map((routeJson) => Route.fromJson(routeJson))
          .toList(),
      totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
    );
  }
}
