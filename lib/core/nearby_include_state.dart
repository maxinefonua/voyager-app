import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/services/country_service.dart';

class NearbyIncludeState extends StatefulWidget {
  final bool isDeparture;
  final CountryService countryService;
  const NearbyIncludeState({
    super.key,
    required this.isDeparture,
    required this.countryService,
  });

  @override
  State<NearbyIncludeState> createState() => _NearbyIncludeStateState();
}

class _NearbyIncludeStateState extends State<NearbyIncludeState> {
  final ValueNotifier<Set<String>> selectedOrigins = ValueNotifier<Set<String>>(
    {},
  );
  final ValueNotifier<Set<String>> selectedDestinations =
      ValueNotifier<Set<String>>({});

  // Track initial selections
  late Set<String> _initialOrigins;
  late Set<String> _initialDestinations;

  @override
  void initState() {
    super.initState();
    // Get initial selections from searchState
    final searchState = context.read<FlightSearchState>();
    _initialOrigins = Set<String>.from(
      searchState.addDepartureAirports.map((airport) => airport.iata),
    );
    _initialDestinations = Set<String>.from(
      searchState.addDestinationAirports.map((airport) => airport.iata),
    );

    // Initialize the ValueNotifiers with initial values
    selectedOrigins.value = Set<String>.from(_initialOrigins);
    selectedDestinations.value = Set<String>.from(_initialDestinations);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    Airport origin;
    Airport destination;
    List<Airport> nearbyOrigins;
    List<Airport> nearbyDestinations;

    if (widget.isDeparture) {
      origin = searchState.departureAirport!;
      destination = searchState.destinationAirport!;
      nearbyOrigins = searchState.nearbyDepartureAirports;
      nearbyDestinations = searchState.nearbyDestinationAirports;
    } else {
      origin = searchState.destinationAirport!;
      destination = searchState.departureAirport!;
      nearbyOrigins = searchState.nearbyDestinationAirports;
      nearbyDestinations = searchState.nearbyDepartureAirports;
    }
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildHeader(searchState),
          // Tab Bar
          _buildTabBar(origin.iata, destination.iata, context),
          // Tab Content
          Expanded(
            child: TabBarView(
              children: [
                // First tab content
                Column(
                  children: [
                    Divider(height: 0),
                    _buildAirportHeader(origin),
                    Divider(height: 0),
                    Expanded(
                      child: _buildAirportsList(
                        widget.isDeparture,
                        nearbyOrigins.skip(1).toList(),
                        origin,
                      ),
                    ),
                  ],
                ),

                // Second tab content
                Column(
                  children: [
                    Divider(height: 0),
                    _buildAirportHeader(destination),
                    Divider(height: 0),
                    Expanded(
                      child: _buildAirportsList(
                        !widget.isDeparture,
                        nearbyDestinations.skip(1).toList(),
                        destination,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirportsList(
    bool isOrigin,
    List<Airport> airports,
    Airport selectedAirport,
  ) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: isOrigin ? selectedOrigins : selectedDestinations,
      builder: (context, selectedSet, child) {
        return ListView.separated(
          padding: EdgeInsets.only(top: 8),
          itemCount: airports.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final airport = airports[index];
            final isSelected = selectedSet.contains(airport.iata);
            final subtitle = _buildSubtitle(airport, selectedAirport);

            return ListTile(
              title: Text(
                airport.name,
                maxLines: 2,
                style: TextStyle(fontSize: 14, overflow: TextOverflow.fade),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    maxLines: 2,
                    style: TextStyle(overflow: TextOverflow.fade),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).splashColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${airport.distance?.toStringAsFixed(1)} km from ${selectedAirport.iata}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  airport.iata,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              trailing: Checkbox(
                activeColor: Colors.blue,
                value: isSelected,
                onChanged: (value) {
                  final newSet = Set<String>.from(selectedSet);
                  if (value == true) {
                    newSet.add(airport.iata);
                  } else {
                    newSet.remove(airport.iata);
                  }
                  if (isOrigin) {
                    selectedOrigins.value = newSet;
                  } else {
                    selectedDestinations.value = newSet;
                  }
                },
              ),
              onTap: () {
                final newSet = Set<String>.from(selectedSet);
                if (newSet.contains(airport.iata)) {
                  newSet.remove(airport.iata);
                } else {
                  newSet.add(airport.iata);
                }
                if (isOrigin) {
                  selectedOrigins.value = newSet;
                } else {
                  selectedDestinations.value = newSet;
                }
              },
            );
          },
        );
      },
    );
  }

  String _buildSubtitle(Airport airport, Airport selectedAirport) {
    final sb = StringBuffer();
    sb.write('${airport.city}, ${airport.subdivision}');
    if (airport.countryCode != selectedAirport.countryCode) {
      sb.write(
        ' in ${widget.countryService.getCountry(airport.countryCode)?.name}',
      );
    }
    return sb.toString();
  }

  Widget _buildHeader(FlightSearchState searchState) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby Airports',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 6),
              Text(
                'Save to add to flight search',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () => _handleSaved(searchState, context),
            child: Text('Save'),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    String originCode,
    String desinationCode,
    BuildContext context,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: [
          Tab(text: originCode),
          Tab(text: desinationCode),
        ],
      ),
    );
  }

  Widget _buildAirportHeader(Airport airport) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(5),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    airport.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${airport.city}, ${airport.subdivision}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                airport.iata,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaved(FlightSearchState searchState, BuildContext context) {
    final currentOrigins = selectedOrigins.value;
    final currentDestinations = selectedDestinations.value;

    // Check if any changes were made
    final originsChanged = !setEquals(currentOrigins, _initialOrigins);
    final destinationsChanged = !setEquals(
      currentDestinations,
      _initialDestinations,
    );

    // If no changes, just close
    if (!originsChanged && !destinationsChanged) {
      Navigator.pop(context);
      return;
    }

    if (originsChanged && destinationsChanged) {
      // Both changed
      searchState.updateSearch(
        addDepartureCodes: currentOrigins,
        addDestinationCodes: currentDestinations,
      );
    } else if (originsChanged) {
      // Only origins changed
      searchState.updateSearch(addDepartureCodes: currentOrigins);
    } else if (destinationsChanged) {
      // Only destinations changed
      searchState.updateSearch(addDestinationCodes: currentDestinations);
    }

    // Always close the screen after saving
    Navigator.pop(context);
  }
}
