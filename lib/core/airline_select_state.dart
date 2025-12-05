import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/filters/airline_option_list.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineSelectState extends StatefulWidget {
  final Airline? selectedAirline;
  final List<Airline>? enabledAirlines;
  const AirlineSelectState({
    super.key,
    required this.selectedAirline,
    required this.enabledAirlines,
  });

  @override
  State<AirlineSelectState> createState() => _AirlineSelectStateState();
}

class _AirlineSelectStateState extends State<AirlineSelectState> {
  late Airline? _currentSelection;
  late List<Airline>? _enabledAirlines;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedAirline;
    _enabledAirlines = widget.enabledAirlines;
    _searchQuery = '';
  }

  @override
  void didUpdateWidget(AirlineSelectState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAirline != oldWidget.selectedAirline) {
      setState(() {
        _currentSelection = widget.selectedAirline;
      });
    }
    if (widget.enabledAirlines != oldWidget.enabledAirlines) {
      setState(() {
        _enabledAirlines = widget.enabledAirlines;
      });
    }
  }

  void _selectAirline(Airline? airline) {
    setState(() {
      _currentSelection = airline;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
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
          child: AirlineOptionList(
            selectedAirline: _currentSelection,
            enabledAirlines: _enabledAirlines,
            onAirlineSelected: _selectAirline,
            searchQuery: _searchQuery,
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
                    if (_currentSelection != widget.selectedAirline) {
                      if (_currentSelection == null) {
                        searchState.clearAirline();
                      } else {
                        searchState.updateSearch(
                          selectedAirline: _currentSelection,
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
          hintText: 'Search airlines...',
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
        'Select Airline',
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
