import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/content/search_card.dart';
import 'package:voyager/content/search_flights_button.dart';
import 'package:voyager/core/flight_search_state.dart';

class HomeAppBody extends StatelessWidget {
  const HomeAppBody({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildSearchContent(context, searchState),
      ),
    );
  }

  Widget _buildSearchContent(
    BuildContext context,
    FlightSearchState searchState,
  ) {
    return Column(
      children: [
        _buildHeader(),
        SizedBox(height: 24),
        SearchCard(),
        SearchFlightsButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Flights',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'an exhaustive search of all possible routes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
