import 'package:voyager/models/airline/airline.dart';

class Flight {
  final int id;
  final String flightNumber;
  final int routeId;
  final DateTime zonedDateTimeDeparture;
  final DateTime zonedDateTimeArrival;
  final bool isActive;
  final Airline airline;

  Flight({
    required this.id,
    required this.flightNumber,
    required this.routeId,
    required this.zonedDateTimeDeparture,
    required this.zonedDateTimeArrival,
    required this.isActive,
    required this.airline,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: (json['id'] as int).toInt(),
      flightNumber: json['flightNumber'],
      routeId: (json['routeId'] as int).toInt(),
      zonedDateTimeDeparture: DateTime.parse(json['zonedDateTimeDeparture']),
      zonedDateTimeArrival: DateTime.parse(json['zonedDateTimeArrival']),
      isActive: json['isActive'] as bool,
      airline: Airline.fromName(json['airline']),
    );
  }
}
