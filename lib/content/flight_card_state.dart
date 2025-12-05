import 'package:flutter/material.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/models/flight/flight_detailed.dart';
import 'package:voyager/services/timezone/timezone_service_interface.dart';
import 'package:voyager/utils/format.dart';

class FlightPathCard extends StatefulWidget {
  final List<FlightDetailed> flightPath;
  final Map<String, Airport> airportMap;
  final TimezoneService timezoneService;
  const FlightPathCard({
    super.key,
    required this.flightPath,
    required this.airportMap,
    required this.timezoneService,
  });

  @override
  State<FlightPathCard> createState() => _FlightPathCardState();
}

class _FlightPathCardState extends State<FlightPathCard>
    with AutomaticKeepAliveClientMixin {
  late final List<FlightDetailed> _flightPath;
  late final Map<String, Airport> _airportMap;
  late final TimezoneService _timezoneService;
  late final Airport _startingAirport;
  late final Airport _finalAirport;
  late final DateTime _localDeparture;
  late final DateTime _localArrival;
  late final bool _nonSameDayArrival;
  late final List<Widget> _children;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _flightPath = widget.flightPath;
    _airportMap = widget.airportMap;
    _timezoneService = widget.timezoneService;
    _startingAirport = _airportMap[_flightPath.first.origin]!;
    _finalAirport = _airportMap[_flightPath.last.destination]!;
    _localDeparture = _timezoneService.getLocalDateTime(
      _flightPath.first.zonedDateTimeDeparture,
      _startingAirport.zoneId,
    );

    _localArrival = _timezoneService.getLocalDateTime(
      _flightPath.last.zonedDateTimeArrival,
      _finalAirport.zoneId,
    );

    _nonSameDayArrival = _localDeparture.day != _localArrival.day;

    _children = _buildChildren();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint(
      'FlightPathCard BUILD: ${widget.flightPath.first.origin}-${widget.flightPath.last.destination}',
    );
    return Card(
      margin: _flightPath.length > 2
          ? EdgeInsets.all(16.0)
          : EdgeInsets.all(8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: _children),
      ),
    );
  }

  List<Widget> _buildChildren() {
    return [
      ..._flightPath.asMap().entries.map((entry) {
        final index = entry.key;
        final flight = entry.value;
        final previousFlight = index > 0 ? _flightPath[index - 1] : null;

        return Column(
          children: [
            // Conditionals based on previous flight
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
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
            _buildFlightEntry(flight, _timezoneService, context),
          ],
        );
      }),
      if (_nonSameDayArrival)
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Chip(
            label: Text(
              'Arrives ${_timezoneService.formatDay(_flightPath.last.zonedDateTimeArrival, _finalAirport.zoneId)} to ${_finalAirport.city}',
            ),
            backgroundColor: Colors.blueGrey,
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
    ];
  }

  Widget _buildFlightEntry(
    FlightDetailed flight,
    TimezoneService timezoneService,
    BuildContext context,
  ) {
    Airport? originAirport = _airportMap[flight.origin];
    Airport? destinationAirport = _airportMap[flight.destination];
    String? departureTimezone = originAirport?.zoneId;
    String? arrivalTimezone = destinationAirport?.zoneId;
    return ListTile(
      leading: SizedBox(
        width: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Align to start
          children: [
            Row(
              children: [
                Icon(Icons.flight_takeoff, size: 20),
                SizedBox(width: 8),
                Text(
                  (departureTimezone != null)
                      ? '${timezoneService.formatTime(flight.zonedDateTimeDeparture, departureTimezone)} ${flight.origin}'
                      : '${flight.origin} flight times TBD',
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.flight_land, size: 20),
                SizedBox(width: 8),
                Text(
                  (arrivalTimezone != null)
                      ? '${timezoneService.formatTime(flight.zonedDateTimeArrival, arrivalTimezone)} ${flight.destination}'
                      : '${flight.destination} Flight times TBD',
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
      title: LayoutBuilder(
        builder: (context, constraints) {
          final fullText =
              '${flight.flightNumber} Flight to ${destinationAirport?.city}, ${destinationAirport?.subdivision}';
          final textPainter = TextPainter(
            text: TextSpan(text: fullText),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          // If text overflows in single line, use line break
          if (textPainter.didExceedMaxLines) {
            return Text(
              '${flight.flightNumber} Flight to\n${destinationAirport?.city}, ${destinationAirport?.subdivision}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          } else {
            return Text(fullText, maxLines: 2, overflow: TextOverflow.ellipsis);
          }
        },
      ),
      subtitle: Text(
        '${flight.airline.displayText} • Duration: ${formatDuration(flight.zonedDateTimeDeparture, flight.zonedDateTimeArrival)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLayoverChip(
    FlightDetailed previousFlight,
    FlightDetailed flight,
    BuildContext context,
  ) {
    Airport? airport = _airportMap[flight.origin];
    DateTime arrival = airport != null
        ? _timezoneService.getLocalDateTime(
            previousFlight.zonedDateTimeArrival,
            airport.zoneId,
          )
        : flight.zonedDateTimeDeparture;

    DateTime departure = airport != null
        ? _timezoneService.getLocalDateTime(
            flight.zonedDateTimeDeparture,
            airport.zoneId,
          )
        : flight.zonedDateTimeDeparture;
    if (arrival.day != departure.day) {
      return Chip(
        label: Text('+${departure.day - arrival.day} day'),
        backgroundColor: ColorScheme.fromSeed(seedColor: Colors.blue).primary,
        labelStyle: TextStyle(color: Colors.white),
      );
    }
    Duration layoverDuration = departure.difference(arrival);
    return Chip(
      label: Text(
        '${formatDuration(previousFlight.zonedDateTimeArrival, flight.zonedDateTimeDeparture)} layover',
      ),
      backgroundColor: layoverDuration.inHours == 0
          ? ColorScheme.fromSeed(seedColor: Colors.blue).error
          : null,
      labelStyle: TextStyle(
        color: layoverDuration.inHours == 0
            ? ColorScheme.fromSeed(seedColor: Colors.blue).inversePrimary
            : null,
      ),
    );
  }
}
