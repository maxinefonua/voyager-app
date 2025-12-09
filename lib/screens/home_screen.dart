import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/content/search_flights_button.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/input/airport_input.dart';
import 'package:voyager/input/date_picker.dart';

class HomeAppBody extends StatelessWidget {
  const HomeAppBody({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildSearchContent(context, searchState),
      ),
    );
  }

  Widget _buildSearchContent(
    BuildContext context,
    FlightSearchState searchState,
  ) {
    return Column(
      children: [
        _buildHeader(),
        SizedBox(height: 24),
        _buildSearchCard(searchState),
        SearchFlightsButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Flights',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Colors.grey[800],
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'an exhaustive search of all possible routes',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard(FlightSearchState searchState) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTripTypeToggle(searchState),
            SizedBox(height: 20),
            _buildAirportInputs(searchState),
            SizedBox(height: 16),
            _buildDateInputs(searchState),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeToggle(FlightSearchState searchState) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('One-way')),
          ButtonSegment(value: true, label: Text('Round-trip')),
        ],
        selected: {searchState.isRoundTrip},
        onSelectionChanged: (Set<bool> newSelection) {
          searchState.setIsRoundTrip(newSelection.last);
        },
      ),
    );
  }

  Widget _buildAirportInputs(FlightSearchState searchState) {
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
              filled: true,
              fillColor: Colors.white,
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
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed:
                (searchState.departureAirport != null ||
                    searchState.destinationAirport != null)
                ? searchState.reverseAirports
                : null,
            icon: Icon(Icons.swap_horiz, color: Colors.blue[600]),
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
              filled: true,
              fillColor: Colors.white,
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
