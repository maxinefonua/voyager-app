import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/input/nearby_option_list.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/services/country_service.dart';

class NearbySelectState extends StatefulWidget {
  final Airport selectedAirport;
  final List<Airport> nearbyAirports;
  final Set<String> addedCodes;
  final bool isOrigin;
  final CountryService countryService;
  const NearbySelectState({
    super.key,
    required this.selectedAirport,
    required this.nearbyAirports,
    required this.addedCodes,
    required this.isOrigin,
    required this.countryService,
  });

  @override
  State<NearbySelectState> createState() => _NearbySelectStateState();
}

class _NearbySelectStateState extends State<NearbySelectState> {
  late Airport _selectedAirport;
  late List<Airport> _nearbyAirports;
  late Set<String> _addedCodes;
  late String _searchQuery;
  late CountryService _countryService;

  @override
  void initState() {
    super.initState();
    _selectedAirport = widget.selectedAirport;
    _nearbyAirports = widget.nearbyAirports
        .where((airport) => airport.iata != _selectedAirport.iata)
        .toList();
    _addedCodes = widget.addedCodes;
    _searchQuery = '';
    _countryService = widget.countryService;
  }

  @override
  void didUpdateWidget(NearbySelectState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAirport != oldWidget.selectedAirport) {
      setState(() {
        _selectedAirport = widget.selectedAirport;
      });
    }
    if (widget.addedCodes != oldWidget.addedCodes) {
      setState(() {
        _addedCodes = widget.addedCodes;
      });
    }
  }

  void _addNearbyCode(String code) {
    setState(() {
      _addedCodes.add(code);
    });
  }

  void _removeNearbyCode(String code) {
    setState(() {
      _addedCodes.remove(code);
    });
  }

  bool _setsAreEqual<T>(Set<T> set1, Set<T> set2) {
    if (set1.length != set2.length) return false;
    for (final element in set1) {
      if (!set2.contains(element)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    final Set<String> addedToSearch = widget.isOrigin
        ? searchState.addDepartureAirports
              .map((airport) => airport.iata)
              .toSet()
        : searchState.addDestinationAirports
              .map((airport) => airport.iata)
              .toSet();
    return Column(
      children: [
        _buildDragHandle(),
        SizedBox(height: 16),
        _buildHeader(),
        SizedBox(height: 8),
        _buildSearchBar(),
        SizedBox(height: 16),
        Divider(height: 0),
        Expanded(
          child: NearbyOptionList(
            selectedAirport: _selectedAirport,
            nearbyAirports: _nearbyAirports,
            addedCodes: _addedCodes,
            searchQuery: _searchQuery,
            onCodeAdded: _addNearbyCode,
            onCodeRemoved: _removeNearbyCode,
            countryService: _countryService,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[800],
                  ),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (!_setsAreEqual(_addedCodes, addedToSearch)) {
                      if (widget.isOrigin) {
                        searchState.updateSearch(
                          addDepartureCodes: _addedCodes,
                        );
                      } else {
                        searchState.updateSearch(
                          addDestinationCodes: _addedCodes,
                        );
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search nearby airports...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        autofocus: false,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Add Nearby Airports',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
