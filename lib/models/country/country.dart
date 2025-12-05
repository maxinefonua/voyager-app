import 'package:voyager/models/country/bounds.dart';

class Country {
  final String code;
  final String name;
  final int population;
  final String capitalCity;
  final double areaInSqKm;
  final String continent;
  final Bounds bounds;
  Country({
    required this.code,
    required this.name,
    required this.population,
    required this.capitalCity,
    required this.areaInSqKm,
    required this.continent,
    required this.bounds,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] as String,
      name: json['name'] as String,
      population: json['population'] as int,
      capitalCity: json['capitalCity'] as String,
      areaInSqKm: (json['areaInSqKm'] as num).toDouble(),
      continent: json['continent'] as String,
      bounds: Bounds.fromJson(json['bounds'] as List<dynamic>),
    );
  }
}
