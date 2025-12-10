import 'package:flutter/material.dart';
import 'package:voyager/content/flight_entry_tile.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/models/flight/flight_detailed.dart';
import 'package:voyager/utils/format.dart';

class FlightPathCard extends StatelessWidget {
  final List<FlightDetailed> flightPath;
  final Map<String, Airport> airportMap;

  const FlightPathCard({
    super.key,
    required this.flightPath,
    required this.airportMap,
  });

  @override
  Widget build(BuildContext context) {
    final lastDestination = flightPath.last.destination;
    // Check if we have valid airport data
    final finalAirport = airportMap[lastDestination];
    if (finalAirport == null) {
      debugPrint('Missing airport data for: $lastDestination');
      return _buildErrorCard(context, 'Missing airport data');
    }
    DateTime localDeparture = flightPath.first.zonedDateTimeDeparture;
    DateTime localArrival = flightPath.last.zonedDateTimeArrival;

    bool nonSameDayArrival = localDeparture.day != localArrival.day;

    return Card(
      margin: flightPath.length > 2
          ? EdgeInsets.all(16.0)
          : EdgeInsets.all(8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ...flightPath.asMap().entries.map((entry) {
              final index = entry.key;
              final flight = entry.value;
              final previousFlight = index > 0 ? flightPath[index - 1] : null;

              return Column(
                children: [
                  if (previousFlight != null) ...[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLayoverChip(previousFlight, flight, context),
                            if (previousFlight.airline != flight.airline)
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Chip(
                                  label: Text('Airline change'),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  FlightEntryTile(
                    flightLocalTimes: flight,
                    originAirport: airportMap[flight.origin]!,
                    destinationAirport: airportMap[flight.destination]!,
                  ),
                ],
              );
            }),
            if (nonSameDayArrival)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Chip(
                  label: Text(
                    'Arrives ${formatDay(flightPath.last.zonedDateTimeArrival, finalAirport.zoneId)} to ${finalAirport.city}',
                  ),
                  backgroundColor: Theme.of(context).hintColor,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoverChip(
    FlightDetailed previousFlight,
    FlightDetailed flight,
    BuildContext context,
  ) {
    DateTime arrival = previousFlight.zonedDateTimeArrival;
    DateTime departure = flight.zonedDateTimeDeparture;
    if (arrival.day != departure.day) {
      return Chip(
        label: Text('+${departure.day - arrival.day} day'),
        backgroundColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(color: Colors.white),
      );
    }
    Duration layoverDuration = departure.difference(arrival);
    return Chip(
      label: Text(
        '${formatDuration(previousFlight.zonedDateTimeArrival, flight.zonedDateTimeDeparture)} layover',
      ),
      backgroundColor: layoverDuration.inHours == 0
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).hintColor.withAlpha(10),
      labelStyle: TextStyle(
        color: layoverDuration.inHours == 0
            ? Theme.of(context).colorScheme.inversePrimary
            : Theme.of(context).hintColor,
      ),
    );
  }
}
