import 'package:flutter/material.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/utils/search.dart';

class AirportInput extends StatelessWidget {
  final InputDecoration inputDecoration;
  final ValueChanged<Airport> onSelected;
  final Airport? selectedAirport; // Receive selected airport from parent
  final Airport? otherAirport; // Add this to check against the other field
  final bool isOrigin;
  final FlightSearchState searchState;

  const AirportInput({
    super.key,
    required this.inputDecoration,
    required this.onSelected,
    this.selectedAirport,
    this.otherAirport,
    required this.searchState,
    required this.isOrigin,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: inputDecoration,
      onTap: () => showAirportSearch(
        context,
        inputDecoration,
        isOrigin,
        isOrigin
            ? searchState.setDepartureAirport
            : searchState.setDestinationAirport,
        otherAirport,
      ),
      controller: TextEditingController(
        text: selectedAirport != null ? selectedAirport!.iata : '',
      ),
    );
  }
}
