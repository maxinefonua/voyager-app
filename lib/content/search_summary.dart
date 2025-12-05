import 'package:flutter/material.dart';
import 'package:voyager/content/airport_circle.dart';
import 'package:voyager/content/nearby_dialog.dart';
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
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: _buildOriginToDestinationContent(context, origin, destination),
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => NearbyDialog(
          isDeparture: isDeparture,
          countryService: countryService,
        ),
      ),
      child: Text(
        'ⓘ Tap for Airport Details',
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOriginToDestinationContent(
    BuildContext context,
    Airport origin,
    Airport destination,
  ) {
    return Row(
      children: [
        AirportCircleIcon(isOrigin: isDeparture, airport: origin, size: 32),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildAirportText(
                      context,
                      origin,
                      origin.countryCode != destination.countryCode,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).shadowColor,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildAirportText(
                      context,
                      destination,
                      destination.countryCode != origin.countryCode,
                    ),
                  ),
                ],
              ),

              _buildInfoButton(context),
            ],
          ),
        ),
        SizedBox(width: 8),
        AirportCircleIcon(
          isOrigin: !isDeparture,
          airport: destination,
          size: 32,
        ),
      ],
    );
  }

  Widget _buildAirportText(
    BuildContext context,
    Airport airport,
    bool differentCountry,
  ) {
    return Text(
      '${airport.city}, ${airport.subdivision}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).shadowColor,
      ),
      maxLines: 1,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }
}
