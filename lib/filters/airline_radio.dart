import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineDropdown extends StatelessWidget {
  static final List<Airline> airlines = Airline.sortedValues();

  const AirlineDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    final Airline? selectedAirline = searchState.selectedAirline;
    final List<Airline>? enabledAirlines = searchState.enabledAirlines;

    return GestureDetector(
      onTap: () => _showAirlineBottomSheet(
        context,
        selectedAirline,
        airlines,
        enabledAirlines,
        searchState,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.airlines, size: 20, color: Colors.grey[700]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedAirline?.displayText ?? 'All Airlines',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showAirlineBottomSheet(
    BuildContext context,
    Airline? selectedAirline,
    List<Airline> airlines,
    List<Airline>? enabledAirlines,
    FlightSearchState searchState,
  ) {
    String searchQuery = '';
    // Create keys for scrolling
    final GlobalKey allAirlinesKey = GlobalKey();
    final Map<Airline, GlobalKey> airlineKeys = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter airlines based on search query
            final filteredAirlines = airlines.where((airline) {
              if (searchQuery.isEmpty) return true;
              return airline.displayText.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  airline.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
            }).toList();

            // Scroll to selected option after the bottom sheet is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (selectedAirline == null) {
                // Scroll to "All Airlines"
                if (allAirlinesKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    allAirlinesKey.currentContext!,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: 0.3,
                  );
                }
              } else if (airlineKeys.containsKey(selectedAirline)) {
                final key = airlineKeys[selectedAirline]!;
                if (key.currentContext != null) {
                  Scrollable.ensureVisible(
                    key.currentContext!,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: 0.3,
                  );
                }
              }
            });

            // Function to handle airline selection
            void _handleAirlineSelection(Airline? airline) {
              if (airline != selectedAirline) {
                searchState.updateSearch(selectedAirline: airline);
              }
              Navigator.pop(context); // Close after selection
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Header with title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Select Airline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Search box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      autofocus: false,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Results count
                  if (searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            '${filteredAirlines.length} result${filteredAirlines.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          if (filteredAirlines.isEmpty)
                            Expanded(
                              child: Text(
                                ' - No airlines found',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  SizedBox(height: 8),

                  // Airline list with Radio buttons
                  Expanded(
                    child: filteredAirlines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.airplanemode_inactive,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No airlines found',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try a different search',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                // "All Airlines" option as Radio with key
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: ListTile(
                                    key:
                                        allAirlinesKey, // Add key for scrolling
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.all_inclusive,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      'All Airlines',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    trailing: Radio<Airline?>(
                                      value: null,
                                      groupValue: selectedAirline,
                                      onChanged: (value) {
                                        _handleAirlineSelection(value);
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    onTap: () {
                                      _handleAirlineSelection(null);
                                    },
                                  ),
                                ),
                                Divider(),

                                // Airline options with Radio buttons
                                ...filteredAirlines.map((airline) {
                                  final isEnabled =
                                      enabledAirlines?.contains(airline) ??
                                      true;
                                  final key = GlobalKey();
                                  airlineKeys[airline] = key; // Store the key

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: ListTile(
                                      key: key, // Assign the key for scrolling
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isEnabled
                                              ? (selectedAirline == airline
                                                    ? Colors.blue[100]
                                                    : Colors.blue[50])
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.airlines,
                                          size: 20,
                                          color: isEnabled
                                              ? (selectedAirline == airline
                                                    ? Colors.blue[700]
                                                    : Colors.blue[500])
                                              : Colors.grey[400],
                                        ),
                                      ),
                                      title: Text(
                                        airline.displayText,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isEnabled
                                              ? Colors.grey[800]
                                              : Colors.grey[400],
                                          fontWeight: isEnabled
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: Radio<Airline?>(
                                        value: airline,
                                        groupValue: selectedAirline,
                                        onChanged: isEnabled
                                            ? (value) {
                                                _handleAirlineSelection(value);
                                              }
                                            : null,
                                        activeColor: Colors.blue,
                                      ),
                                      onTap: isEnabled
                                          ? () {
                                              _handleAirlineSelection(airline);
                                            }
                                          : null,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                  ),

                  // Single close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Close'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
