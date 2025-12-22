import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/content/bottom_bar.dart';
import 'package:voyager/content/path_results_state.dart';
import 'package:voyager/content/search_summary.dart';
import 'package:voyager/core/airline_check_content.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/filters/date_filter.dart';
import 'package:voyager/models/airline/airline.dart';
import 'package:voyager/services/country_service.dart';

class FlightResultsScaffold extends StatelessWidget {
  const FlightResultsScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    final countryService = context.read<CountryService>();
    final allSelected =
        searchState.includedAirlines.length == Airline.values.length;
    final airlineText = allSelected
        ? 'Multi-Airlines'
        : searchState.includedAirlines.first.displayText;
    final plusAirlineCount = searchState.includedAirlines.length - 1;

    return DefaultTabController(
      length: searchState.returnDate != null ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Flights'),
          backgroundColor: Colors.blue,
          actions: [
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: AirlineCheckContent(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
              ),
              child: Badge(
                label: Text('+$plusAirlineCount'),
                offset: Offset(16, -8),
                isLabelVisible: plusAirlineCount > 0,
                child: Text(airlineText),
              ),
            ),
            SizedBox(width: 30),
          ],
        ),
        body: Column(
          children: [
            if (searchState.returnDate != null)
              TabBar(
                tabs: [
                  Tab(text: 'Departure'),
                  Tab(text: 'Return'),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFlightResults(searchState, countryService, true),
                  if (searchState.returnDate != null)
                    _buildFlightResults(searchState, countryService, false),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: TabAwareBottomBar(
          isUpdating: searchState.isUpdating,
        ),
      ),
    );
  }

  Widget _buildFlightResults(
    FlightSearchState searchState,
    CountryService countryService,
    bool isDeparture,
  ) {
    return Column(
      children: [
        SearchSummaryContent(
          countryService: countryService,
          searchState: searchState,
          isDeparture: isDeparture,
        ),
        DateFilter(searchState: searchState, isDeparture: isDeparture),
        PathResults(isDeparture: isDeparture),
      ],
    );
  }
}
