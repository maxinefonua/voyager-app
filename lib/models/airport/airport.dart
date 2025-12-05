class Airport {
  final String iata;
  final String name;
  final String city;
  final String subdivision;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String type;
  final String zoneId;
  final double? distance;

  Airport({
    required this.iata,
    required this.name,
    required this.city,
    required this.subdivision,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.zoneId,
    this.distance,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      iata: json['iata'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      subdivision: json['subdivision'] ?? '',
      countryCode: json['countryCode'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? '',
      zoneId: json['zoneId'] ?? '',
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}
