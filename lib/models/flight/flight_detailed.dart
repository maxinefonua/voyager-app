import 'package:voyager/models/airline/airline.dart';
import 'package:voyager/services/timezone/timezone_service.dart';
import 'package:voyager/utils/format.dart';

class FlightDetailed {
  final String flightNumber;
  final String origin;
  final String destination;
  final DateTime zonedDateTimeDeparture;
  final DateTime zonedDateTimeArrival;
  final Airline airline;
  final Duration duration;
  final double distanceKm;

  const FlightDetailed({
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.zonedDateTimeDeparture,
    required this.zonedDateTimeArrival,
    required this.airline,
    required this.duration,
    required this.distanceKm,
  });

  factory FlightDetailed.fromJson(Map<String, dynamic> json) {
    return FlightDetailed(
      flightNumber: json['flightNumber'],
      origin: json['origin'],
      destination: json['destination'],
      zonedDateTimeDeparture: DateTime.parse(json['zonedDateTimeDeparture']),
      zonedDateTimeArrival: DateTime.parse(json['zonedDateTimeArrival']),
      airline: Airline.fromName(json['airline']),
      duration: parseJavaDuration(json['duration']),
      distanceKm: (json['distanceKm'] as num).toDouble(),
    );
  }

  FlightDetailed withLocalTimes({
    required TimezoneService timezoneService,
    required String departureTimezone,
    required String arrivalTimezone,
  }) {
    return FlightDetailed(
      flightNumber: flightNumber,
      origin: origin,
      destination: destination,
      zonedDateTimeDeparture: timezoneService.getLocalDateTime(
        zonedDateTimeDeparture,
        departureTimezone,
      ),
      zonedDateTimeArrival: timezoneService.getLocalDateTime(
        zonedDateTimeArrival,
        arrivalTimezone,
      ),
      airline: airline,
      duration: duration,
      distanceKm: distanceKm,
    );
  }
}
