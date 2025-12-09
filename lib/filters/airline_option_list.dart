import 'package:flutter/material.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineOptionList extends StatelessWidget {
  final Airline? selectedAirline;
  final List<Airline>? enabledAirlines;
  final ValueChanged<Airline?> onAirlineSelected;
  final String searchQuery;
  final bool showDisabled;

  static final List<Airline> airlineValues = Airline.sortedValues();

  const AirlineOptionList({
    super.key,
    required this.selectedAirline,
    required this.enabledAirlines,
    required this.onAirlineSelected,
    required this.searchQuery,
    required this.showDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final filteredAirlines = airlineValues.where((airline) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesSearch =
            airline.displayText.toLowerCase().contains(query) ||
            airline.name.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }
      final isEnabled = enabledAirlines?.contains(airline) ?? true;
      return showDisabled || isEnabled;
    }).toList();

    // Create keys for scrolling
    final GlobalKey allAirlinesKey = GlobalKey();
    final Map<Airline, GlobalKey> airlineKeys = {};

    return Builder(
      builder: (context) {
        // Scroll to selected item after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (selectedAirline == null) {
            if (allAirlinesKey.currentContext != null) {
              Scrollable.ensureVisible(
                allAirlinesKey.currentContext!,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: 0.3, // 0 = top, 1 = bottom, 0.3 = 30% from top
              );
            }
          } else if (airlineKeys.containsKey(selectedAirline)) {
            final key = airlineKeys[selectedAirline]!;
            if (key.currentContext != null) {
              Scrollable.ensureVisible(
                key.currentContext!,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: 0.3,
              );
            }
          }
        });

        return RadioGroup<Airline?>(
          groupValue: selectedAirline,
          onChanged: onAirlineSelected,
          child: Column(
            children: [
              _buildAllAirlinesOption(key: allAirlinesKey),
              Divider(height: 0),
              if (searchQuery.isNotEmpty && filteredAirlines.isEmpty)
                Expanded(child: _buildNoResults()),
              if (searchQuery.isEmpty && filteredAirlines.isEmpty)
                Expanded(child: _buildNoEnabledAirlines()),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // Airline options
                      ...filteredAirlines.map((airline) {
                        final key = GlobalKey();
                        airlineKeys[airline] =
                            key; // Store key for this airline
                        return _buildAirlineOption(airline, key: key);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAirlineOption(Airline airline, {GlobalKey? key}) {
    final isEnabled = enabledAirlines?.contains(airline) ?? true;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => onAirlineSelected(airline) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: airline == selectedAirline ? Colors.grey[100] : null,
          child: ListTile(
            key: key,
            enabled: isEnabled,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isEnabled ? Colors.blue[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.airlines,
                size: 20,
                color: isEnabled ? Colors.blue[500] : Colors.grey[400],
              ),
            ),
            title: Text(
              airline.displayText,
              style: TextStyle(
                fontSize: 16,
                color: isEnabled ? Colors.grey[800] : Colors.grey[400],
                fontWeight: isEnabled ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            trailing: Radio<Airline?>(
              enabled: isEnabled,
              value: airline,
              toggleable: true,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAllAirlinesOption({GlobalKey? key}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAirlineSelected(null),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: selectedAirline == null ? Colors.grey[100] : null,
          child: ListTile(
            title: Text(
              'Multi-Airline',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Radio<Airline?>(value: null, toggleable: true),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildNoEnabledAirlines() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.connecting_airports, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Airlines Enabled for Filtering',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Any flight paths are via multi-airline connections',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
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
            'No airlines found',
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
}
