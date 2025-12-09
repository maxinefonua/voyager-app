import 'package:flutter/material.dart';
import 'package:voyager/models/airline/airline.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/models/exception/cancelled_exception.dart';
import 'package:voyager/models/path/path_detailed.dart';
import 'package:voyager/models/voyager/path_request.dart';
import 'package:voyager/services/airline_service.dart';
import 'package:voyager/services/airport_cache.dart';
import 'package:voyager/services/path_service.dart';
import 'dart:async';
import 'package:async/async.dart';

class FlightSearchState with ChangeNotifier {
  final _pathService = PathService();
  final _airportCache = AirportCache();

  CancelableOperation? _departureLoadMoreOperation;
  CancelableOperation? _returnLoadMoreOperation;
  bool _departureLoadMoreCancelled = false;
  bool _returnLoadMoreCancelled = false;

  Airport? _departureAirport;
  List<Airport> _addDepartureAirports = [];
  List<Airport> _nearbyDepartureAirports = [];
  Airport? _destinationAirport;
  List<Airport> _addDestinationAirports = [];
  List<Airport> _nearbyDestinationAirports = [];
  DateTime _departureDate;
  DateTime? _lastReturnDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  List<Airline>? _enabledAirlines;
  Airline? _selectedAirline;
  bool _isLoadingPathResponse = false;
  bool _isUpdating = false;
  bool _isUpdatingDeparture = false;
  bool _isUpdatingReturn = false;
  bool _isLoadingReturnResponse = false;

  bool _setParamsWithoutUpdate = false;

  bool get isUpdating => _isUpdating;
  bool get isUpdatingDeparture => _isUpdatingDeparture;
  bool get isUpdatingReturn => _isUpdatingReturn;
  bool get isLoadingPathResponse => _isLoadingPathResponse;
  bool get isLoadingReturnResponse => _isLoadingReturnResponse;

  // for load more
  List<PathDetailed> _departurePaths = [];
  List<PathDetailed>? _returnPaths = [];
  bool _hasMoreDepartures = true;
  bool _hasMoreReturns = true;
  String? _departureError;
  String? _returnError;
  PathRequest? _pathRequestDeparture;
  PathRequest? _pathRequestReturn;

  List<PathDetailed> get departurePaths => _departurePaths;
  List<Airport> get nearbyDepartureAirports => _nearbyDepartureAirports;
  List<Airport> get nearbyDestinationAirports => _nearbyDestinationAirports;
  bool get hasMoreDepartures => _hasMoreDepartures;
  bool get hasMoreReturns => _hasMoreReturns;
  String? get departureError => _departureError;
  String? get returnError => _returnError;
  PathRequest? get pathRequestDeparture => _pathRequestDeparture;
  PathRequest? get pathRequestReturn => _pathRequestReturn;

  // Initialize with default date
  FlightSearchState() : _departureDate = DateTime.now();

  // Getters
  Airport? get departureAirport => _departureAirport;
  List<Airport> get addDepartureAirports => _addDepartureAirports;
  Airport? get destinationAirport => _destinationAirport;
  List<Airport> get addDestinationAirports => _addDestinationAirports;
  DateTime get departureDate => _departureDate;
  DateTime? get returnDate => _returnDate;
  bool get isRoundTrip => _isRoundTrip;
  List<PathDetailed>? get returnPaths => _returnPaths;
  Airline? get selectedAirline => _selectedAirline;
  List<Airline>? get enabledAirlines => _enabledAirlines;

  bool get canSearch =>
      _departureAirport != null &&
      _destinationAirport != null &&
      (!_isRoundTrip || _returnDate != null);

  // Methods to update state
  Future<void> updateSearch({
    Airport? departureAirport,
    Airport? destinationAirport,
    Set<String>? addDepartureCodes,
    Set<String>? addDestinationCodes,
    DateTime? departureDate,
    DateTime? returnDate,
    bool? isRoundTrip,
    Airline? selectedAirline,
    bool? clearSelectedAirline,
  }) async {
    cancelLoadMore();
    try {
      _isUpdating = true;

      bool didAirportsChange =
          departureAirport != null ||
          destinationAirport != null ||
          addDepartureCodes != null ||
          addDestinationCodes != null;
      _isUpdatingDeparture =
          didAirportsChange ||
          departureDate != null ||
          selectedAirline != _selectedAirline;
      _isUpdatingReturn =
          didAirportsChange ||
          returnDate != null ||
          selectedAirline != _selectedAirline;

      _isLoadingPathResponse =
          didAirportsChange ||
          departureDate != null ||
          selectedAirline != _selectedAirline;
      if (_returnDate != null) {
        _isLoadingReturnResponse =
            didAirportsChange ||
            returnDate != null ||
            selectedAirline != _selectedAirline;
      }

      _departureAirport = departureAirport ?? _departureAirport;

      _destinationAirport = destinationAirport ?? _destinationAirport;
      _departureDate = departureDate ?? _departureDate;
      _isRoundTrip = isRoundTrip ?? _isRoundTrip;
      _returnDate = returnDate ?? _returnDate;
      _selectedAirline = selectedAirline ?? _selectedAirline;

      if (_departureAirport == null) {
        _addDepartureAirports = [];
        _nearbyDepartureAirports = [];
      } else {
        if (addDepartureCodes != null) {
          _addDepartureAirports = nearbyDepartureAirports
              .where((airport) => addDepartureCodes.contains(airport.iata))
              .toList();
        }
      }
      if (_destinationAirport == null) {
        _addDestinationAirports = [];
        _nearbyDestinationAirports = [];
      } else {
        if (addDestinationCodes != null) {
          _addDestinationAirports = nearbyDestinationAirports
              .where((airport) => addDestinationCodes.contains(airport.iata))
              .toList();
        }
      }

      if (_setParamsWithoutUpdate) {
        _isUpdatingDeparture = true;
        _isUpdatingReturn = true;
      }

      notifyListeners();

      if (canSearch) {
        _enabledAirlines = await AirlineService().fetchAirlines(
          [_departureAirport!.iata],
          [_destinationAirport!.iata],
        );
        if (_enabledAirlines != null && _selectedAirline != null) {
          if (!_enabledAirlines!.contains(_selectedAirline)) {
            _selectedAirline = null;
          }
        }
        notifyListeners();

        _nearbyDepartureAirports = await _airportCache.fetchNearbyAirports(
          _departureAirport!.iata,
          _selectedAirline,
        );

        _nearbyDestinationAirports = await _airportCache.fetchNearbyAirports(
          _destinationAirport!.iata,
          _selectedAirline,
        );

        notifyListeners();
        _pathRequestDeparture = PathRequest(
          originList: [
            _departureAirport!.iata,
            ...addDepartureAirports.map((depature) => depature.iata),
          ],
          destinationList: [
            _destinationAirport!.iata,
            ...addDestinationAirports.map((destination) => destination.iata),
          ],
          airline: _selectedAirline,
          timezoneId: _departureAirport!.zoneId,
          startTime: _departureDate,
        );
        final response = await _pathService.fetchPaths(_pathRequestDeparture!);
        _departurePaths = response.content;
        _isLoadingPathResponse = false;
        _hasMoreDepartures = response.hasMore;
        _isUpdatingDeparture = false;
        notifyListeners();

        if (_returnDate != null) {
          _isLoadingReturnResponse = true;
          _pathRequestReturn = PathRequest(
            originList: [
              _destinationAirport!.iata,
              ...addDestinationAirports.map((destination) => destination.iata),
            ],
            destinationList: [
              _departureAirport!.iata,
              ...addDepartureAirports.map((depature) => depature.iata),
            ],
            airline: _selectedAirline,
            timezoneId: _destinationAirport!.zoneId,
            startTime: _returnDate!,
          );
          final returnResponse = await _pathService.fetchPaths(
            _pathRequestReturn!,
          );
          _hasMoreReturns = returnResponse.hasMore;
          if (returnResponse.content.isNotEmpty) {
            _returnPaths = returnResponse.content;
          } else {
            _returnPaths = [
              PathDetailed(
                flightPathList: List.empty(),
                iataList: [_destinationAirport!.iata, _departureAirport!.iata],
                pathOrigin: _destinationAirport!.iata,
                pathDestination: _departureAirport!.iata,
                totalDistanceKm: 0,
              ),
            ];
          }
          _isLoadingReturnResponse = false;
          _isUpdatingReturn = false;
        } else {
          _returnPaths = [];
        }
      } else {
        _departurePaths = [];
        _returnPaths = [];
        _enabledAirlines = null;
        _nearbyDepartureAirports = [];
        _nearbyDestinationAirports = [];
      }
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Load more results - append to existing list
  Future<void> loadMore(bool isDeparture) async {
    // Check if previous operation was cancelled
    if ((isDeparture && _departureLoadMoreCancelled) ||
        (!isDeparture && _returnLoadMoreCancelled)) {
      // Reset cancellation flag
      if (isDeparture) {
        _departureLoadMoreCancelled = false;
      } else {
        _returnLoadMoreCancelled = false;
      }
      return;
    }

    if ((isDeparture &&
            (!_hasMoreDepartures ||
                _isLoadingPathResponse ||
                _pathRequestDeparture == null)) ||
        (!isDeparture &&
            (!_hasMoreReturns ||
                _isLoadingReturnResponse ||
                _pathRequestReturn == null))) {
      return;
    }

    try {
      if (isDeparture) {
        _isLoadingPathResponse = true;
        notifyListeners();

        // Wrap the fetch operation in a CancelableOperation
        _departureLoadMoreOperation = CancelableOperation.fromFuture(
          _pathService.fetchNextPage(
            _pathRequestDeparture!,
            _departurePaths.length,
          ),
        );

        final withNextBatch = await _departureLoadMoreOperation!.value;
        _departurePaths = withNextBatch.content;
        _hasMoreDepartures = withNextBatch.hasMore;
        _departureLoadMoreOperation = null;
      } else {
        _isLoadingReturnResponse = true;
        notifyListeners();

        // Wrap the fetch operation in a CancelableOperation
        _returnLoadMoreOperation = CancelableOperation.fromFuture(
          _pathService.fetchNextPage(_pathRequestReturn!, _returnPaths!.length),
        );

        final withNextBatch = await _returnLoadMoreOperation!.value;
        _returnPaths = withNextBatch.content;
        _hasMoreReturns = withNextBatch.hasMore;
        _returnLoadMoreOperation = null;
      }
    } catch (e) {
      if (e is CancelledException) {
        debugPrint(
          'Load more cancelled for ${isDeparture ? 'departure' : 'return'}',
        );
        // Set cancellation flag
        if (isDeparture) {
          _departureLoadMoreCancelled = true;
        } else {
          _returnLoadMoreCancelled = true;
        }
      } else {
        debugPrint(
          'failed to loadMore with isDeparture: $isDeparture, error: ${e.toString()}',
        );
      }
    } finally {
      if (isDeparture) {
        _isLoadingPathResponse = false;
        _departureLoadMoreOperation = null;
      } else {
        _isLoadingReturnResponse = false;
        _returnLoadMoreOperation = null;
      }
      notifyListeners();
    }
  }

  void cancelLoadMore() {
    if (_departureLoadMoreOperation != null) {
      _departureLoadMoreOperation!.cancel();
      _departureLoadMoreOperation = null;
      _departureLoadMoreCancelled = true;
    }

    if (_returnLoadMoreOperation != null) {
      _returnLoadMoreOperation!.cancel();
      _returnLoadMoreOperation = null;
      _returnLoadMoreCancelled = true;
    }
  }

  void setDepartureAirport(Airport airport) {
    if (_departureAirport?.iata == airport.iata) return;
    _departureAirport = airport;
    _addDepartureAirports.clear();
    _departurePaths.clear();
    _returnPaths?.clear;
    notifyListeners();
  }

  void setDestinationAirport(Airport airport) {
    if (_destinationAirport?.iata == airport.iata) return;
    _destinationAirport = airport;
    _addDestinationAirports.clear();
    _departurePaths.clear();
    _returnPaths?.clear;
    notifyListeners();
  }

  void setDepartureDate(DateTime date) {
    _departureDate = date;
    _departurePaths.clear();
    notifyListeners();
  }

  void setReturnDate(DateTime? date) {
    _returnDate = date;
    _returnPaths?.clear();
    notifyListeners();
  }

  void setIsRoundTrip(bool roundTrip) {
    _setParamsWithoutUpdate = true;
    if (!roundTrip && _isRoundTrip) {
      _lastReturnDate = returnDate;
      _returnDate = null;
    }
    if (roundTrip && !_isRoundTrip) {
      _returnDate =
          _lastReturnDate != null &&
              (_lastReturnDate!.isAfter(_departureDate) ||
                  _lastReturnDate!.isAtSameMomentAs(_departureDate))
          ? _lastReturnDate
          : null;
      _lastReturnDate = null;
      _returnPaths?.clear();
    }
    _isRoundTrip = roundTrip;
    notifyListeners();
  }

  void clearAirline() {
    _selectedAirline = null;
    _isUpdating = true;
    _isUpdatingDeparture = true;
    _isUpdatingReturn = true;
    notifyListeners();
    updateSearch();
  }

  void reverseAirports() {
    final temp = _departureAirport;
    _departureAirport = _destinationAirport;
    _destinationAirport = temp;
    final tempAdds = _addDepartureAirports;
    _addDepartureAirports = _addDestinationAirports;
    _addDestinationAirports = tempAdds;
    _departurePaths.clear();
    _returnPaths?.clear();
    notifyListeners();
  }

  void clearSearch() {
    _departureAirport = null;
    _addDepartureAirports = [];
    _destinationAirport = null;
    _addDestinationAirports = [];
    _departureDate = DateTime.now();
    _returnDate = null;
    _enabledAirlines = null;
    notifyListeners();
  }

  void clearDestinationAirport() {
    _destinationAirport = null;
    notifyListeners();
  }
}
