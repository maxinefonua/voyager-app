import 'package:flutter/material.dart';
import 'package:voyager/content/nearby_airports_button.dart';
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

    return Container(
      padding: EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAirportBadge(isDeparture, origin),
              _buildAirportNameSection(origin, destination),
              _buildAirportBadge(!isDeparture, destination),
            ],
          ),
          SizedBox(height: 5),
          NearbyAirportsButton(
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

  Widget _buildAirportNameSection(Airport origin, Airport destination) {
    return Text(
      '${origin.city} → ${destination.city}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    );
  }
}
