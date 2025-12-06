import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/core/nearby_select_state.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/services/country_service.dart';

class AirportCircleIcon extends StatelessWidget {
  final bool isOrigin;
  final Airport airport;
  final int? badgeCount;

  const AirportCircleIcon({
    super.key,
    required this.isOrigin,
    required this.airport,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    final countryService = context.watch<CountryService>();
    final circleColor = isOrigin ? Colors.blue : Colors.green;
    final hasBadge = badgeCount != null && badgeCount! > 0;

    return FloatingActionButton.small(
      onPressed: () {
        _buildContent(context, searchState, countryService);
      },
      heroTag: 'airport_${airport.iata}',
      backgroundColor: Colors.white,
      foregroundColor: circleColor,
      elevation: 1,
      shape: CircleBorder(
        side: BorderSide(color: circleColor.withAlpha((255 * 0.3).round())),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Text(
              airport.iata,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),

          if (hasBadge)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    badgeCount! > 9 ? '+9' : badgeCount.toString(),
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _buildContent(
    BuildContext context,
    FlightSearchState searchState,
    CountryService countryService,
  ) {
    debugPrint('buildContent');
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
          child: NearbySelectState(
            selectedAirport: airport,
            nearbyAirports: isOrigin
                ? searchState.nearbyDepartureAirports
                : searchState.nearbyDestinationAirports,
            addedCodes: isOrigin
                ? searchState.addDepartureAirports
                      .map((airport) => airport.iata)
                      .toSet()
                : searchState.addDestinationAirports
                      .map((airport) => airport.iata)
                      .toSet(),
            isOrigin: isOrigin,
            countryService: countryService,
          ),
        );
      },
    );
  }
}
