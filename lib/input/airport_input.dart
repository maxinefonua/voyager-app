import 'package:flutter/material.dart';
import 'package:voyager/core/airport_search_state.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airport/airport.dart';

class AirportInput extends StatelessWidget {
  final InputDecoration inputDecoration;
  final ValueChanged<Airport> onSelected;
  final Airport? selectedAirport; // Receive selected airport from parent
  final Airport? otherAirport; // Add this to check against the other field
  final Set<String> otherAirportCodes;
  final bool isOrigin;
  final FlightSearchState searchState;

  const AirportInput({
    super.key,
    required this.inputDecoration,
    required this.onSelected,
    this.selectedAirport,
    this.otherAirport,
    required this.otherAirportCodes,
    required this.searchState,
    required this.isOrigin,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: inputDecoration,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
            selectedAirport: selectedAirport,
            otherAirportCodes: otherAirportCodes,
          ),
        ),
      ),
      controller: TextEditingController(
        text: selectedAirport != null ? selectedAirport!.iata : '',
      ),
    );
  }
}
