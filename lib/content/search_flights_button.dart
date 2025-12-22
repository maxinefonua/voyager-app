import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/screens/flights_screen.dart';

class SearchFlightsButton extends StatelessWidget {
  const SearchFlightsButton({super.key});

  @override
  Widget build(BuildContext context) {
    FlightSearchState searchState = context.watch<FlightSearchState>();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _getOnPressed(context, searchState),
          style: _getButtonStyle(searchState),
          child: _buildChild(searchState),
        ),
      ),
    );
  }

  VoidCallback? _getOnPressed(
    BuildContext context,
    FlightSearchState searchState,
  ) {
    if (!searchState.canSearch || searchState.isUpdating) {
      return null;
    }

    return () async {
      try {
        searchState.updateSearch();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FlightResultsScaffold()),
          );
        }
      } catch (e) {
        // Handle any immediate errors
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
        }
      }
    };
  }

  ButtonStyle _getButtonStyle(FlightSearchState searchState) {
    return ElevatedButton.styleFrom(
      backgroundColor: searchState.canSearch
          ? Colors.blue[600]
          : Colors.grey[400],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildChild(FlightSearchState searchState) {
    if (searchState.isUpdating) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    return const Text('Search Flights', style: TextStyle(fontSize: 16));
  }
}
