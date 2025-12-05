import 'package:flutter/material.dart';
import 'package:voyager/models/airport/airport.dart';

class AirportCircleIcon extends StatelessWidget {
  final bool isOrigin;
  final Airport airport;
  final double size;
  const AirportCircleIcon({
    super.key,
    required this.isOrigin,
    required this.airport,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = isOrigin ? Colors.blue : Colors.green;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: circleColor.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: circleColor.withAlpha((255 * 0.3).round()),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          airport.iata,
          style: TextStyle(
            fontSize: size * .4,
            fontWeight: FontWeight.w700,
            color: circleColor,
          ),
        ),
      ),
    );
  }
}
