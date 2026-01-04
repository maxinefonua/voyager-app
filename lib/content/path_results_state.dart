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
  final Map<String, GlobalKey> _tileKeys = {};
  late bool _nonEmptyPathFound;

  @override
  void initState() {
    super.initState();
    _isDeparture = widget.isDeparture;
    _nonEmptyPathFound = false;
  }

  @override
  void didUpdateWidget(covariant PathResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isNavigatingBack = false;
    _nonEmptyPathFound = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToExpandedTile(String pathKey) {
    // Check if key exists in the map
    if (!_tileKeys.containsKey(pathKey)) {
      debugPrint('Warning: Key $pathKey not found in tileKeys map');
      debugPrint('Available keys: ${_tileKeys.keys}');
      return;
    }

    final key = _tileKeys[pathKey];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      } else {
        debugPrint('Warning: Key context is null for $pathKey');
      }
    });
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

  String _generatePathKey(PathDetailed path, int index) {
    return '${path.hashCode}_${path.displayText}_$index';
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();

    final List<PathDetailed>? paths = _isDeparture
        ? searchState.departurePaths
        : searchState.returnPaths;

    final isUpdating = _isDeparture
        ? searchState.isUpdatingDeparture
        : searchState.isUpdatingReturn;

    // Show loading indicator when paths is null or empty
    if (paths == null || paths.isEmpty) {
      return _buildLoadingIndicator();
    }

    final airportCache = context.read<AirportCache>();
    final timezoneService = context.read<TimezoneService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_nonEmptyPathFound) {
        _loadMore();
      }
    });

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              if (paths.length > 1)
                ListView.builder(
                  controller: _scrollController,
                  addAutomaticKeepAlives: true,
                  itemCount: paths.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= paths.length) {
                      return SizedBox(height: 20);
                    }
                    final path = paths[index];
                    final String pathKey = _generatePathKey(path, index);
                    if (!_tileKeys.containsKey(pathKey)) {
                      _tileKeys[pathKey] = GlobalKey();
                    }
                    final List<Airport> airportList = path.iataList
                        .map((iata) => airportCache.getAirport(iata)!)
                        .toList();
                    final subtitle = _buildSubtitle(
                      path,
                      airportList,
                      searchState.departureAirport!.iata,
                      searchState.destinationAirport!.iata,
                    );
                    Map<String, Airport> airportMap = {};
                    for (String iata in path.iataList) {
                      airportMap[iata] = airportCache.getAirport(iata)!;
                    }
                    final localizedFlights = _buildFlightsWithLocalTimes(
                      path,
                      timezoneService,
                      airportMap,
                    );
                    bool initiallyExpand = false;
                    if (localizedFlights.isNotEmpty && !_nonEmptyPathFound) {
                      initiallyExpand = true;
                      _nonEmptyPathFound = true;
                    }

                    return PathTile(
                      localizedFlights: localizedFlights,
                      airportMap: airportMap,
                      timezoneService: timezoneService,
                      subtitle: subtitle,
                      pathDisplay: path.displayText,
                      initiallyExpanded: initiallyExpand,
                      key: _tileKeys[pathKey],
                      isDepartureTile: _isDeparture,
                      isEnabled: localizedFlights.isNotEmpty,
                      onExpanded: () => _scrollToExpandedTile(pathKey),
                      height: constraints.maxHeight,
                      isLast: index == paths.length - 1,
                    );
                  },
                ),
              if (paths.length == 1)
                Builder(
                  builder: (context) {
                    final path = paths[0];
                    final String pathKey = _generatePathKey(path, 0);
                    if (!_tileKeys.containsKey(pathKey)) {
                      _tileKeys[pathKey] = GlobalKey();
                    }
                    final List<Airport> airportList = path.iataList
                        .map((iata) => airportCache.getAirport(iata)!)
                        .toList();
                    final subtitle = _buildSubtitle(
                      path,
                      airportList,
                      searchState.departureAirport!.iata,
                      searchState.destinationAirport!.iata,
                    );
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
                      onExpanded: () => _scrollToExpandedTile(pathKey),
                      key: _tileKeys[pathKey],
                      height: constraints.maxHeight,
                      isDepartureTile: _isDeparture,
                      isEnabled: localizedFlights.isNotEmpty,
                      isLast: true,
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

  String _buildSubtitle(
    PathDetailed path,
    List<Airport> airportList,
    String departureCode,
    String destinationCode,
  ) {
    if (path.iataList.length == 2) {
      final sb = StringBuffer();
      if (path.flightPathList.isEmpty) {
        sb.write('No direct flights');
      } else {
        if (path.flightPathList.length == 1) {
          sb.write('${path.flightPathList.length} direct flight');
        } else {
          sb.write('${path.flightPathList.length} direct flights');
        }
      }
      if ((widget.isDeparture && path.pathOrigin != departureCode) ||
          (!widget.isDeparture && path.pathOrigin != destinationCode)) {
        sb.write(' from ${airportList.first.city}');
      }
      if ((widget.isDeparture && path.pathDestination != destinationCode) ||
          (!widget.isDeparture && path.pathDestination != departureCode)) {
        sb.write(' to ${airportList.last.city}');
      }
      return sb.toString();
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
