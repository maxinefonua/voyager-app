import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/airline_select_state.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineFilter extends StatelessWidget {
  static final List<Airline> airlines = Airline.sortedValues();

  const AirlineFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    final Airline? selectedAirline = searchState.selectedAirline;
    final List<Airline>? enabledAirlines = searchState.enabledAirlines;

    return GestureDetector(
      onTap: () => _showAirlineBottomSheet(
        context,
        selectedAirline,
        airlines,
        enabledAirlines,
        searchState,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.airlines, size: 20, color: Colors.grey[700]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedAirline?.displayText ?? 'All Airlines',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showAirlineBottomSheet(
    BuildContext context,
    Airline? selectedAirline,
    List<Airline> airlines,
    List<Airline>? enabledAirlines,
    FlightSearchState searchState,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AirlineSelectState(
            selectedAirline: selectedAirline,
            enabledAirlines: enabledAirlines,
          ),
        );
      },
    );
  }
}
