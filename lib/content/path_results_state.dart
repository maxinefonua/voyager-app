import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/content/path_tile_state.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/models/flight/flight_detailed.dart';
import 'package:voyager/models/path/path_detailed.dart';
import 'package:voyager/services/airport_cache.dart';
import 'package:voyager/services/timezone/timezone_service.dart';

class PathResults extends StatefulWidget {
  final bool isDeparture;
  const PathResults({super.key, required this.isDeparture});

  @override
  State<PathResults> createState() => PathResultsState();
}

class PathResultsState extends State<PathResults> {
  final _scrollController = ScrollController();
  late final bool _isDeparture;
  bool _isNavigatingBack = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _isDeparture = widget.isDeparture;
  }

  @override
  void didUpdateWidget(covariant PathResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isNavigatingBack = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNavigatingBack) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> handleBackButton() async {
    final searchState = context.read<FlightSearchState>();
    bool isLoadingMore = _isDeparture
        ? searchState.isLoadingPathResponse
        : searchState.isLoadingReturnResponse;

    if (isLoadingMore) {
      // Set flag to prevent any new loadMore calls
      setState(() {
        _isNavigatingBack = true;
      });

      // Cancel the loadMore operation
      searchState.cancelLoadMore();

      // Wait a moment for the cancellation to take effect
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _loadMore() {
    if (_isNavigatingBack) return;
    final searchState = context.read<FlightSearchState>();
    bool isLoadingMore = _isDeparture
        ? searchState.isLoadingPathResponse
        : searchState.isLoadingReturnResponse;
    bool hasMore = _isDeparture
        ? searchState.hasMoreDepartures
        : searchState.hasMoreReturns;
    if (!isLoadingMore && hasMore) {
      searchState.loadMore(_isDeparture);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    final paths = _isDeparture
        ? searchState.departurePaths
        : searchState.returnPaths!;
    final isUpdating = _isDeparture
        ? searchState.isUpdatingDeparture
        : searchState.isUpdatingReturn;

    // Show initial loading only when there are originally no paths
    if (paths.isEmpty) {
      return _buildLoadingIndicator();
    }

    debugPrint('PathResults build with ${paths.length} paths');
    final airportCache = context.read<AirportCache>();
    final timezoneService = context.read<TimezoneService>();

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          debugPrint('Available height: ${constraints.maxHeight}');
          return Stack(
            children: [
              if (paths.length > 1)
                ListView.builder(
                  controller: _scrollController,
                  addAutomaticKeepAlives: true,
                  itemCount: paths.length,
                  itemBuilder: (context, index) {
                    final path = paths[index];
                    final List<Airport> airportList = path.iataList
                        .map((iata) => airportCache.getAirport(iata)!)
                        .toList();
                    final subtitle = _buildSubtitle(path, airportList);
                    Map<String, Airport> airportMap = {};
                    for (String iata in path.iataList) {
                      airportMap[iata] = airportCache.getAirport(iata)!;
                    }
                    final localizedFlights = _buildFlightsWithLocalTimes(
                      path,
                      timezoneService,
                      airportMap,
                    );

                    return PathTile(
                      localizedFlights: localizedFlights,
                      airportMap: airportMap,
                      timezoneService: timezoneService,
                      subtitle: subtitle,
                      pathDisplay: path.displayText,
                      initiallyExpanded: index == 0,
                      constrainList: paths.length > 1,
                      key: ValueKey('path_${path.hashCode}_$index'),
                      isDepartureTile: _isDeparture,
                      isEnabled: localizedFlights.isNotEmpty,
                    );
                  },
                ),
              if (paths.length == 1)
                Builder(
                  builder: (context) {
                    final path = paths[0];
                    final List<Airport> airportList = path.iataList
                        .map((iata) => airportCache.getAirport(iata)!)
                        .toList();
                    final subtitle = _buildSubtitle(path, airportList);
                    Map<String, Airport> airportMap = {};
                    for (String iata in path.iataList) {
                      airportMap[iata] = airportCache.getAirport(iata)!;
                    }
                    final localizedFlights = _buildFlightsWithLocalTimes(
                      path,
                      timezoneService,
                      airportMap,
                    );

                    return PathTile(
                      localizedFlights: localizedFlights,
                      airportMap: airportMap,
                      timezoneService: timezoneService,
                      subtitle: subtitle,
                      pathDisplay: path.displayText,
                      initiallyExpanded: true,
                      constrainList: paths.length > 1,
                      key: ValueKey('path_${path.hashCode}_0'),
                      height: constraints.maxHeight,
                      isDepartureTile: _isDeparture,
                      isEnabled: false,
                    );
                  },
                ),
              if (isUpdating)
                Container(
                  color: Colors.black54, // Semi-transparent overlay
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Updating...', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _buildSubtitle(PathDetailed path, List<Airport> airportList) {
    if (path.iataList.length == 2) {
      if (path.flightPathList.isEmpty) {
        return 'No direct flights';
      } else {
        if (path.flightPathList.length == 1) {
          return '${path.flightPathList.length} direct flight';
        }
        return '${path.flightPathList.length} direct flights';
      }
    } else {
      final midAirportCities = airportList
          .sublist(1, airportList.length - 1)
          .map((airport) => '${airport.city}, ${airport.subdivision}');
      final sb = StringBuffer();
      if (path.flightPathList.length > 1) {
        sb.write('${path.flightPathList.length} connections in ');
      } else {
        sb.write('${path.flightPathList.length} connection in ');
      }
      sb.write(midAirportCities.join(' and '));
      return sb.toString();
    }
  }

  List<List<FlightDetailed>> _buildFlightsWithLocalTimes(
    PathDetailed path,
    TimezoneService timezoneService,
    Map<String, Airport> airportMap,
  ) {
    return path.flightPathList
        .map(
          (flightPath) => flightPath
              .map(
                (flight) => flight.withLocalTimes(
                  timezoneService: timezoneService,
                  departureTimezone: airportMap[flight.origin]!.zoneId,
                  arrivalTimezone: airportMap[flight.destination]!.zoneId,
                ),
              )
              .toList(),
        )
        .toList();
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0), // Add padding around the button
        child: SizedBox(
          width: double.infinity, // Expands horizontally
          child: Text(
            'Initiating flight search...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ),
    );
  }
}
