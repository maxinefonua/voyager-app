import 'package:flutter/material.dart';
import 'package:voyager/content/airport_details_button.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/services/country_service.dart';

class SearchSummaryContent extends StatelessWidget {
  final FlightSearchState searchState;
  final CountryService countryService;
  final bool isDeparture;
  const SearchSummaryContent({
    super.key,
    required this.searchState,
    required this.countryService,
    required this.isDeparture,
  });

  @override
  Widget build(BuildContext context) {
    Airport origin = searchState.departureAirport!;
    Airport destination = searchState.destinationAirport!;
    if (!isDeparture) {
      origin = searchState.destinationAirport!;
      destination = searchState.departureAirport!;
    }

    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAirportBadge(isDeparture, origin),
              SizedBox(width: 12),
              _buildAirportNameSection(origin, destination),
              SizedBox(width: 12),
              _buildAirportBadge(!isDeparture, destination),
            ],
          ),
          AirportDetailsButton(
            isDeparture: isDeparture,
            countryService: countryService,
          ),
        ],
      ),
    );
  }

  Widget _buildAirportBadge(bool isOrigin, Airport airport) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOrigin ? Colors.blue[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOrigin ? Colors.blue[200]! : Colors.green[200]!,
          width: 1,
        ),
      ),
      child: Text(
        airport.iata,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isOrigin ? Colors.blue[700] : Colors.green[700],
        ),
      ),
    );
  }

  _buildAirportNameSection(Airport origin, Airport destination) {
    return Text('${origin.city} → ${destination.city}');
  }
}
