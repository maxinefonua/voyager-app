import 'package:flutter/material.dart';
import 'package:voyager/input/airline_check_list_item.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineCheckList extends StatefulWidget {
  final List<Airline> filteredAirlines;
  final ValueNotifier<Set<Airline>> selectedAirlineNotifier;
  final ValueChanged<Airline> onAirlineChecked;
  final ValueChanged<Airline> onAirlineRemoved;
  final ScrollController? scrollController;
  final Map<String, GlobalKey> itemKeys;
  final ValueNotifier<String?>? scrollToAirlineNotifier;

  const AirlineCheckList({
    super.key,
    required this.selectedAirlineNotifier,
    required this.filteredAirlines,
    required this.onAirlineChecked,
    required this.onAirlineRemoved,
    required this.scrollController,
    required this.itemKeys,
    this.scrollToAirlineNotifier,
  });

  @override
  State<AirlineCheckList> createState() => _AirlineCheckListState();
}

class _AirlineCheckListState extends State<AirlineCheckList> {
  bool _hasScrolledToFirstSelected = false;

  void _scrollToFirstSelected() {
    final selectedSet = widget.selectedAirlineNotifier.value;
    if (selectedSet.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Airline? firstSelected;
      int selectedIndex = -1;

      // Find the first selected airline and its index
      for (int i = 0; i < widget.filteredAirlines.length; i++) {
        final airline = widget.filteredAirlines[i];
        if (selectedSet.contains(airline)) {
          firstSelected = airline;
          selectedIndex = i;
          break;
        }
      }

      if (firstSelected != null &&
          widget.scrollController != null &&
          widget.scrollController!.hasClients) {
        // Calculate position for better scrolling
        final itemHeight = 56.0; // Standard ListTile height
        final viewportHeight = MediaQuery.of(context).size.height;
        final maxExtent = widget.scrollController!.position.maxScrollExtent;

        // Try to position item 1/4 from top of viewport
        double targetOffset =
            selectedIndex * itemHeight - viewportHeight * 0.25;

        // If item is near the end, scroll to show as much as possible
        final estimatedItemBottom = (selectedIndex + 1) * itemHeight;
        if (estimatedItemBottom > maxExtent + viewportHeight * 0.8) {
          // Item is near the bottom, scroll to bottom
          targetOffset = maxExtent;
        } else {
          // Clamp the target offset within valid range
          targetOffset = targetOffset.clamp(0.0, maxExtent);
        }

        widget.scrollController!.animateTo(
          targetOffset,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Schedule scroll after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasScrolledToFirstSelected) {
        _scrollToFirstSelected();
        _hasScrolledToFirstSelected = true;
      }
    });
  }

  @override
  void didUpdateWidget(AirlineCheckList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only scroll again if the filtered list changed significantly
    if (widget.filteredAirlines.length != oldWidget.filteredAirlines.length ||
        widget.selectedAirlineNotifier.value !=
            oldWidget.selectedAirlineNotifier.value) {
      // Reset the flag to allow scrolling again
      _hasScrolledToFirstSelected = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasScrolledToFirstSelected) {
          _scrollToFirstSelected();
          _hasScrolledToFirstSelected = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<Airline>>(
      valueListenable: widget.selectedAirlineNotifier,
      builder: (context, selectedSet, child) {
        final children = ListTile.divideTiles(
          context: context,
          tiles: widget.filteredAirlines
              .map(
                (airline) => AirlineCheckListItem(
                  key: widget.itemKeys[airline.name],
                  airline: airline,
                  isSelected: selectedSet.contains(airline),
                  onChanged: () {
                    if (selectedSet.contains(airline)) {
                      widget.onAirlineRemoved(airline);
                    } else {
                      widget.onAirlineChecked(airline);
                      widget.scrollToAirlineNotifier?.value = airline.name;
                    }
                  },
                ),
              )
              .toList(),
        );
        return ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(top: 8),
          children: [...children],
        );
      },
    );
  }
}
