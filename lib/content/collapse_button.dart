import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/controllers/expansion_state_controller.dart';
import 'package:voyager/core/flight_search_state.dart';

class CollapseButton extends StatelessWidget {
  final bool isDeparture;
  const CollapseButton({super.key, required this.isDeparture});

  @override
  Widget build(BuildContext context) {
    final searchState = context.read<FlightSearchState>();
    final hasConnectionPaths =
        (isDeparture && searchState.departurePaths.length > 1) ||
        (!isDeparture &&
            searchState.returnPaths != null &&
            searchState.returnPaths!.length > 1);
    final isEnabled = !searchState.isUpdating && hasConnectionPaths;
    return ElevatedButton(
      onPressed: isEnabled
          ? () {
              final expansionState = context.read<ExpansionState>();
              if (isDeparture) {
                expansionState.collapseDepartures();
              } else {
                expansionState.collapseReturns();
              }
            }
          : null,
      child: Text('Collapse All'),
    );
  }
}
