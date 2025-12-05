import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/services/airport_cache.dart';

class AirportSearchContent extends StatefulWidget {
  final String title;
  final ValueChanged<Airport> onSelected;
  final Airport? otherAirport;

  const AirportSearchContent({
    super.key,
    required this.title,
    required this.onSelected,
    this.otherAirport,
  });

  @override
  State<AirportSearchContent> createState() => _AirportSearchContentState();
}

class _AirportSearchContentState extends State<AirportSearchContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final airportCache = context.read<AirportCache>();
    final airports = airportCache.getAllAirports();

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        // Search field
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search by city, airport, or code...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onChanged: (value) => setState(() {}),
          ),
        ),

        // Results list
        Expanded(child: _buildAirportsList(airports)),
      ],
    );
  }

  Widget _buildAirportsList(List<Airport> airports) {
    final searchText = _searchController.text.toLowerCase();
    final filteredAirports = airports.where((airport) {
      if (searchText.isEmpty) return false;
      return airport.name.toLowerCase().contains(searchText) ||
          airport.iata.toLowerCase().contains(searchText) ||
          airport.city.toLowerCase().contains(searchText);
    }).toList();

    if (filteredAirports.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Start typing to search airports'
              : 'No airports found for "${_searchController.text}"',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredAirports.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final airport = filteredAirports[index];
        final isDisabled =
            widget.otherAirport != null &&
            widget.otherAirport!.iata == airport.iata;
        return ListTile(
          title: Text(
            airport.name,
            style: TextStyle(color: isDisabled ? Colors.grey[400] : null),
          ),
          subtitle: Text(
            '${airport.iata} • ${airport.city}, ${airport.countryCode}',
            style: TextStyle(color: isDisabled ? Colors.grey[400] : null),
          ),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey[200] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              airport.iata,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDisabled ? Colors.grey[400] : Colors.blue[700],
              ),
            ),
          ),
          onTap: isDisabled
              ? null
              : () {
                  widget.onSelected(airport);
                  Navigator.pop(context);
                },
        );
      },
    );
  }
}
