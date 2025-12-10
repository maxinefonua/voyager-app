import 'package:flutter/material.dart';
import 'package:voyager/core/airport_search_state.dart';
import 'package:voyager/models/airport/airport.dart';

void showAirportSearch(
  BuildContext context,
  InputDecoration inputDecoration,
  bool isOrigin,
  Function(Airport) onSelected,
  Airport? otherAirport,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: AirportSearchContent(
        title: inputDecoration.labelText ?? 'Search Airport',
        onSelected: onSelected,
        otherAirport: otherAirport,
      ),
    ),
  );
}
