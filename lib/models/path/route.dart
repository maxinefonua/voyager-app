class Route {
  final int id;
  final String origin;
  final String destination;
  final double distanceKm;

  Route({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceKm,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: (json['id'] as int).toInt(),
      origin: json['origin'],
      destination: json['destination'],
      distanceKm: (json['distanceKm'] as num).toDouble(),
    );
  }
}
