import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/input/airline_autocomplete.dart';
import 'package:voyager/input/airport_input.dart';
import 'package:voyager/input/date_picker.dart';

class SearchCard extends StatelessWidget {
  const SearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTripTypeToggle(searchState, context),
            SizedBox(height: 20),
            _buildAirportInputs(searchState, context),
            SizedBox(height: 16),
            _buildDateInputs(searchState),
            SizedBox(height: 16),
            AirlineAutocomplete(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeToggle(
    FlightSearchState searchState,
    BuildContext context,
  ) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('One-way')),
        ButtonSegment(value: true, label: Text('Round-trip')),
      ],
      selected: {searchState.isRoundTrip},
      onSelectionChanged: (Set<bool> newSelection) {
        searchState.setIsRoundTrip(newSelection.last);
      },
      style: ButtonStyle(
        // Background color for unselected segments
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blue; // Selected segment color
          }
          return Colors.grey[200]!; // Unselected segment color
        }),
        // Text color
        foregroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // Selected text color
          }
          return Colors.black; // Unselected text color
        }),
      ),
    );
  }

  Widget _buildAirportInputs(
    FlightSearchState searchState,
    BuildContext context,
  ) {
    bool reverseEnabled =
        searchState.departureAirport != null ||
        searchState.destinationAirport != null;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: AirportInput(
            inputDecoration: InputDecoration(
              labelText: 'From',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.flight_takeoff, color: Colors.blue[600]),
            ),
            onSelected: searchState.setDepartureAirport,
            selectedAirport: searchState.departureAirport,
            otherAirport: searchState.destinationAirport,
            isOrigin: true,
            searchState: searchState,
          ),
        ),
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: reverseEnabled
                ? isDarkMode
                      ? Colors.grey[50]
                      : Theme.of(context).primaryColorLight.withAlpha(100)
                : Theme.of(context).disabledColor.withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: reverseEnabled ? searchState.reverseAirports : null,
            icon: Icon(
              Icons.swap_horiz,
              color: reverseEnabled
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: AirportInput(
            inputDecoration: InputDecoration(
              labelText: 'To',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.flight_land, color: Colors.blue[600]),
            ),
            onSelected: searchState.setDestinationAirport,
            selectedAirport: searchState.destinationAirport,
            otherAirport: searchState.departureAirport,
            isOrigin: false,
            searchState: searchState,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInputs(FlightSearchState searchState) {
    return searchState.isRoundTrip
        ? DateRangePickerField(
            label: 'Travel Dates',
            onDateRangeSelected: (range) {
              searchState.setDepartureDate(range.start);
              searchState.setReturnDate(range.end);
            },
            selectedDateRange: searchState.returnDate != null
                ? DateTimeRange(
                    start: searchState.departureDate,
                    end: searchState.returnDate!,
                  )
                : null,
            departureDate: searchState.departureDate,
            firstDate: DateTime.now(),
          )
        : DatePickerField(
            label: 'Departure Date',
            onDateSelected: searchState.setDepartureDate,
            selectedDate: searchState.departureDate,
            firstDate: DateTime.now(),
          );
  }
}
