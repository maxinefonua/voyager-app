import 'package:flutter/material.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/utils/format.dart';

class DateFilter extends StatelessWidget {
  final FlightSearchState searchState;
  final bool isDeparture;
  const DateFilter({
    super.key,
    required this.searchState,
    required this.isDeparture,
  });

  @override
  Widget build(BuildContext context) {
    final onDate = isDeparture
        ? searchState.departureDate
        : searchState.returnDate!;
    final dayBefore = onDate.subtract(Duration(days: 1));
    final dayAfter = onDate.add(Duration(days: 1));
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDateButton(
            icon: Icons.chevron_left,
            onPressed: _isBeforeToday(dayBefore)
                ? null
                : isDeparture
                ? () => searchState.updateSearch(departureDate: dayBefore)
                : dayBefore.isBefore(searchState.departureDate)
                ? () => searchState.updateSearch(
                    departureDate: dayBefore,
                    returnDate: dayBefore,
                  )
                : () => searchState.updateSearch(returnDate: dayBefore),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.date_range,
                size: 16,
                color: Colors.blue[600], // Accent color
              ),
              SizedBox(width: 8),
              Text(
                formatDate(onDate),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),

          // Next day button
          _buildDateButton(
            icon: Icons.chevron_right,
            onPressed: isDeparture
                ? (searchState.returnDate == null)
                      ? () => searchState.updateSearch(departureDate: dayAfter)
                      : (dayAfter.isBefore(searchState.returnDate!))
                      ? () => searchState.updateSearch(departureDate: dayAfter)
                      : () => searchState.updateSearch(
                          departureDate: dayAfter,
                          returnDate: dayAfter,
                        )
                : () => searchState.updateSearch(returnDate: dayAfter),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 20,
      padding: EdgeInsets.all(8),
      constraints: BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }

  bool _isBeforeToday(DateTime dateTime) {
    DateTime today = DateTime.now();
    if (dateTime.year < today.year) return true;
    if (dateTime.year > today.year) return false;
    // year == year
    if (dateTime.month < today.month) return true;
    if (dateTime.month > today.month) return false;
    // month == month
    if (dateTime.day < today.day) return true;
    return false;
  }
}
