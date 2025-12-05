import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineDropdown extends StatelessWidget {
  final List<Airline> airlines = Airline.sortedValues();

  AirlineDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    airlines.sort((a, b) => a.name.compareTo(b.name));
    final searchState = context.watch<FlightSearchState>();
    final Airline? selectedAirline = searchState.selectedAirline;
    final List<Airline>? enabledAirlines = searchState.enabledAirlines;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<Airline>(
        padding: const EdgeInsets.only(left: 15, top: 6, bottom: 6),
        initialValue: selectedAirline, // Use value instead of initialValue
        onChanged: (airline) {
          if (airline == selectedAirline) return;
          searchState.updateSearch(selectedAirline: airline);
        },
        items: [
          const DropdownMenuItem(value: null, child: Text('All Airlines')),
          ...airlines.map((airline) {
            final isEnabled = enabledAirlines?.contains(airline) ?? true;

            return DropdownMenuItem(
              value: airline,
              enabled: isEnabled, // This disables the item
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isEnabled ? Colors.grey[200] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.airlines,
                      size: 16,
                      color: isEnabled ? Colors.black : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    airline.displayText,
                    style: TextStyle(
                      color: isEnabled ? Colors.black : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        decoration: const InputDecoration.collapsed(hintText: 'Select airline'),
        isExpanded: true,
      ),
    );
  }
}
