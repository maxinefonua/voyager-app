import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/services/country_service.dart';

class NearbyDialog extends StatefulWidget {
  final bool isDeparture;
  final CountryService countryService;
  const NearbyDialog({
    super.key,
    required this.isDeparture,
    required this.countryService,
  });

  @override
  State<NearbyDialog> createState() => _NearbyDialogState();
}

class _NearbyDialogState extends State<NearbyDialog> {
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

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              SizedBox(height: 16),
              Text('Include Nearby Airports'),
              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: origin.iata),
                    Tab(text: destination.iata),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    // First tab content
                    Column(
                      children: [
                        // ListView
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Check if there are any changes
            final hasChanges =
                !_setsAreEqual(selectedOrigins.value, _initialOrigins) ||
                !_setsAreEqual(
                  selectedDestinations.value,
                  _initialDestinations,
                );

            if (hasChanges) {
              if (widget.isDeparture) {
                searchState.updateSearch(
                  addDepartureCodes: selectedOrigins.value,
                  addDestinationCodes: selectedDestinations.value,
                );
              } else {
                searchState.updateSearch(
                  addDepartureCodes: selectedDestinations.value,
                  addDestinationCodes: selectedOrigins.value,
                );
              }
            }
            Navigator.pop(context);
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }

  // Helper function to compare sets
  bool _setsAreEqual<T>(Set<T> set1, Set<T> set2) {
    if (set1.length != set2.length) return false;
    for (final element in set1) {
      if (!set2.contains(element)) return false;
    }
    return true;
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
                          color: Colors.grey[700],
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
}
