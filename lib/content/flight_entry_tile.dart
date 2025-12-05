import 'package:flutter/material.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/models/flight/flight_detailed.dart';
import 'package:voyager/utils/format.dart';

class FlightEntryTile extends StatelessWidget {
  final FlightDetailed flightLocalTimes;
  final Airport originAirport;
  final Airport destinationAirport;
  const FlightEntryTile({
    super.key,
    required this.flightLocalTimes,
    required this.originAirport,
    required this.destinationAirport,
  });

  @override
  Widget build(BuildContext context) {
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
                  '${formatTime(flightLocalTimes.zonedDateTimeDeparture)} ${flightLocalTimes.origin}',
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
                  '${formatTime(flightLocalTimes.zonedDateTimeArrival)} ${flightLocalTimes.destination}',
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
              '${flightLocalTimes.flightNumber} Flight to ${destinationAirport.city}, ${destinationAirport.subdivision}';
          final textPainter = TextPainter(
            text: TextSpan(text: fullText),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          // If text overflows in single line, use line break
          if (textPainter.didExceedMaxLines) {
            return Text(
              '${flightLocalTimes.flightNumber} Flight to\n${destinationAirport.city}, ${destinationAirport.subdivision}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          } else {
            return Text(fullText, maxLines: 2, overflow: TextOverflow.ellipsis);
          }
        },
      ),
      subtitle: Text(
        '${flightLocalTimes.airline.displayText} • Duration: ${formatDuration(flightLocalTimes.zonedDateTimeDeparture, flightLocalTimes.zonedDateTimeArrival)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
