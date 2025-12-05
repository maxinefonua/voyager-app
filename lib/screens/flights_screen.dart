import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/content/bottom_bar.dart';
import 'package:voyager/content/path_results_state.dart';
import 'package:voyager/content/search_summary.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/filters/airline_radio.dart';
import 'package:voyager/filters/date_filter.dart';
import 'package:voyager/services/country_service.dart';

class FlightResultsScaffold extends StatelessWidget {
  const FlightResultsScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('FlightResultsScaffold build called');
    final searchState = context.watch<FlightSearchState>();
    final countryService = context.read<CountryService>();

    return DefaultTabController(
      length: searchState.returnDate != null ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(title: Text('Search')),
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
        // SearchSummaryHeader(isDeparture: isDeparture),
        SearchSummaryContent(
          countryService: countryService,
          searchState: searchState,
          isDeparture: isDeparture,
        ),
        Divider(height: 0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AirlineFilter(),
        ),
        DateFilter(searchState: searchState, isDeparture: isDeparture),
        PathResults(isDeparture: isDeparture),
      ],
    );
  }
}
