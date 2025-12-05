import 'package:voyager/models/flight/flight.dart';
import 'package:voyager/models/path/route.dart';

class RouteFlights {
  String origin;
  String destination;
  double distanceKm;
  List<Flight> flightList;
  RouteFlights({
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.flightList,
  });

  factory RouteFlights.fromRouteAndFlightList(
    Route route,
    List<Flight> flightList,
  ) {
    return RouteFlights(
      origin: route.origin,
      destination: route.destination,
      distanceKm: route.distanceKm,
      flightList: flightList,
    );
  }
}
