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
    return ListTile(
      contentPadding: EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 8),
      // visualDensity: VisualDensity.comfortable,
      tileColor: Theme.of(context).cardColor,
      // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AirportCircleIcon(
                isOrigin: isDeparture,
                airport: origin,
                size: 32,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${origin.city}, ${origin.subdivision}',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).shadowColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 20,
                color: Theme.of(context).shadowColor,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${destination.city}, ${destination.subdivision}',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).shadowColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              AirportCircleIcon(
                isOrigin: !isDeparture,
                airport: destination,
                size: 32,
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => NearbyDialog(
          isDeparture: isDeparture,
          countryService: countryService,
        ),
      ),
      subtitle: Text(
        'Tap for nearby airports',
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
