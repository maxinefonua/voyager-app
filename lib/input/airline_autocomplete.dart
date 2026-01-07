import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineAutocomplete extends StatelessWidget {
  const AirlineAutocomplete({super.key});

  static final List<String> _airlines = Airline.sortedValues()
      .map((airline) => airline.displayText)
      .toList();

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    final hasPreference =
        searchState.includedAirlines.length < Airline.values.length;

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _airlines.where((String option) {
          return option.toLowerCase().startsWith(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Set the initial value on the controller
            if (hasPreference && textEditingController.text.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                textEditingController.text =
                    searchState.includedAirlines.first.displayText;
              });
            }

            // Listen to text changes to clear selection when empty
            textEditingController.addListener(() {
              if (textEditingController.text.isEmpty) {
                searchState.clearInitialAilrine();
              }
            });

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Preferred Airline (Optional)',
                hintText: 'Enter airline name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.airlines_rounded,
                  color: Colors.blue[600],
                ),
                suffixIcon: textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          textEditingController.clear();
                          searchState.clearInitialAilrine();
                          focusNode.unfocus();
                        },
                        tooltip: 'Clear airline selection',
                      )
                    : null,
              ),
            );
          },
      onSelected: (String selection) {
        searchState.setInitialAirline(
          Airline.values.firstWhere(
            (airline) => airline.displayText == selection,
          ),
        );
      },
    );
  }
}
