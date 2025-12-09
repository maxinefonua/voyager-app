import 'package:voyager/models/flight/flight_detailed.dart';

class PathDetailed {
  final List<List<FlightDetailed>> flightPathList;
  final List<String> iataList;
  final String pathOrigin;
  final String pathDestination;
  final double totalDistanceKm;

  PathDetailed({
    required this.flightPathList,
    required this.iataList,
    required this.pathOrigin,
    required this.pathDestination,
    required this.totalDistanceKm,
  });

  factory PathDetailed.fromJson(Map<String, dynamic> json) {
    final flightPathList = (json['flightPathList'] as List)
        .whereType<List<dynamic>>() // First filter for lists
        .map(
          (innerList) => (innerList)
              .whereType<
                Map<String, dynamic>
              >() // Then filter maps in inner list
              .map((item) => FlightDetailed.fromJson(item))
              .toList(),
        )
        .toList();
    final iataList = (json['iataList'] as List)
        .whereType<String>() // Filter for strings only
        .toList();
    return PathDetailed(
      flightPathList: flightPathList,
      iataList: iataList,
      pathOrigin: iataList.first,
      pathDestination: iataList.last,
      totalDistanceKm: flightPathList.isNotEmpty
          ? flightPathList.first.fold(0, (sum, item) => sum + item.distanceKm)
          : 0,
    );
  }

  String get displayText => _getDisplayText();

  String _getDisplayText() {
    return iataList.join(' → ');
  }
}
