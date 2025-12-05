import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';

class LoadMoreButton extends StatelessWidget {
  final bool isDeparture;
  const LoadMoreButton({super.key, required this.isDeparture});

  @override
  Widget build(BuildContext context) {
    debugPrint('build LoadMoreButton isDeparture: $isDeparture');
    final searchState = context.watch<FlightSearchState>();
    if (searchState.isUpdating) {
      return _buildDisabledLoadButton();
    }
    bool isLoading = isDeparture
        ? searchState.isLoadingPathResponse
        : searchState.isLoadingReturnResponse;
    bool hasMore = isDeparture
        ? searchState.hasMoreDepartures
        : searchState.hasMoreReturns;
    return _buildLoadButton(isLoading, hasMore, searchState);
  }

  Widget _buildDisabledLoadButton() {
    return ElevatedButton(onPressed: null, child: Text('Load More'));
  }

  Widget _buildLoadButton(
    bool isLoading,
    bool hasMore,
    FlightSearchState searchState,
  ) {
    if (isLoading) {
      return ElevatedButton(
        onPressed: null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(width: 8),
            Text('Loading more...', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: hasMore ? () => searchState.loadMore(isDeparture) : null,
        child: Text(hasMore ? 'Load More' : 'No Further Flights'),
      );
    }
  }
}
