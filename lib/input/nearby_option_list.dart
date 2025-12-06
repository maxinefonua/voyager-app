import 'package:flutter/material.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/services/country_service.dart';

class NearbyOptionList extends StatelessWidget {
  final Airport selectedAirport;
  final List<Airport> nearbyAirports;
  final Set<String> addedCodes;
  final ValueChanged<String> onCodeAdded;
  final ValueChanged<String> onCodeRemoved;
  final String searchQuery;
  final CountryService countryService;

  const NearbyOptionList({
    super.key,
    required this.selectedAirport,
    required this.nearbyAirports,
    required this.addedCodes,
    required this.onCodeAdded,
    required this.onCodeRemoved,
    required this.searchQuery,
    required this.countryService,
  });

  @override
  Widget build(BuildContext context) {
    final filteredAirlines = nearbyAirports.where((airport) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      return airport.name.toLowerCase().contains(query) ||
          airport.city.toLowerCase().contains(query) ||
          airport.iata.toLowerCase().contains(query);
    }).toList();

    if (filteredAirlines.isEmpty) {
      return _buildNoResults();
    }

    return ListView.separated(
      padding: EdgeInsets.only(top: 8),
      itemCount: filteredAirlines.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final airport = filteredAirlines[index];
        final isSelected = addedCodes.contains(airport.iata);
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
              if (value == true) {
                onCodeAdded(airport.iata);
              } else {
                onCodeRemoved(airport.iata);
              }
            },
          ),
          onTap: () {
            if (isSelected) {
              onCodeRemoved(airport.iata);
            } else {
              onCodeAdded(airport.iata);
            }
          },
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airplanemode_inactive, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No matching nearby airports',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Try a different search',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(Airport airport, Airport selectedAirport) {
    final sb = StringBuffer();
    sb.write('${airport.city}, ${airport.subdivision}');
    if (airport.countryCode != selectedAirport.countryCode) {
      sb.write(' in ${countryService.getCountry(airport.countryCode)?.name}');
    }
    return sb.toString();
  }
}
