import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/filters/airline_check_list.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineCheckContent extends StatefulWidget {
  const AirlineCheckContent({super.key});

  @override
  State<AirlineCheckContent> createState() => _AirlineCheckContentState();
}

class _AirlineCheckContentState extends State<AirlineCheckContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late bool _filterSingleCarriers;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<Set<Airline>> selectedAirlines =
      ValueNotifier<Set<Airline>>({});

  late Set<Airline> _initialAirlines;
  late Set<Airline> _singleCarrierAirlines;
  String? _errorMessage;
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    _filterSingleCarriers = false;

    // Get initial selections from searchState
    final searchState = context.read<FlightSearchState>();
    _initialAirlines = Set<Airline>.from(searchState.includedAirlines);
    if (searchState.singleCarrierAirlines != null) {
      _singleCarrierAirlines = Set<Airline>.from(
        searchState.singleCarrierAirlines!,
      );
    } else {
      _singleCarrierAirlines = {};
    }

    // Initialize the ValueNotifiers with initial values
    selectedAirlines.value = Set<Airline>.from(_initialAirlines);

    // Initialize keys for all airlines
    _initializeKeys();
  }

  void _initializeKeys() {
    // Create keys for all airlines initially
    for (final airline in Airline.values) {
      _itemKeys[airline.name] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<FlightSearchState>();
    final filteredAirlines = _getFilteredAirlines();

    return Column(
      children: [
        _buildHeader(searchState),
        if (_errorMessage != null)
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.red[100],
            child: Row(
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                SizedBox(width: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
        _buildSearchBar(),
        Row(
          children: [
            Expanded(
              child: _buildShowSingleAirlineToggle(
                _singleCarrierAirlines.length,
              ),
            ),
            Expanded(child: _buildAllAirlinesTile(filteredAirlines)),
          ],
        ),
        Expanded(child: _buildFilteredResults(filteredAirlines)),
      ],
    );
  }

  Widget _buildNoResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Text(
          'No matching airlines',
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'Try a different search',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildNoSingleCarriers() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Icon(Icons.connecting_airports, size: 48, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text(
          'No single-carrier airlines between airports',
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'Fight paths are by multi-airline connections only',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFilteredResults(List<Airline> filteredAirlines) {
    if (filteredAirlines.isEmpty) {
      if (_filterSingleCarriers && _searchController.text.isEmpty) {
        return _buildNoSingleCarriers();
      } else {
        return _buildNoResults();
      }
    }
    return AirlineCheckList(
      selectedAirlineNotifier: selectedAirlines,
      filteredAirlines: filteredAirlines,
      onAirlineChecked: (airline) {
        setState(() {
          selectedAirlines.value.add(airline);
        });
      },
      onAirlineRemoved: (airline) {
        setState(() {
          selectedAirlines.value.remove(airline);
        });
      },
      scrollController: _scrollController,
      itemKeys: _itemKeys,
    );
  }

  List<Airline> _getFilteredAirlines() {
    return Airline.sortedValues().where((airline) {
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final matchesSearch =
            airline.displayText.toLowerCase().contains(query) ||
            airline.name.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }
      bool isSingleCarrier = _singleCarrierAirlines.contains(airline);
      return !_filterSingleCarriers || isSingleCarrier;
    }).toList();
  }

  Widget _buildAllAirlinesTile(List<Airline> filteredAirlines) {
    final selectedCount = selectedAirlines.value.length;
    final hasSelection = selectedCount > 0;
    final disabled = filteredAirlines.isEmpty && selectedCount == 0;
    final text = hasSelection ? 'Selected' : 'Select';
    return TextButton.icon(
      onPressed: filteredAirlines.isEmpty && selectedCount == 0
          ? null
          : () {
              setState(() {
                if (hasSelection) {
                  selectedAirlines.value = {};
                } else {
                  selectedAirlines.value = filteredAirlines.toSet();
                }
              });
            },
      label: ListTile(
        leading: Badge(
          label: Text(selectedCount.toString()),
          smallSize: 20,
          backgroundColor: hasSelection ? Colors.blue[400] : Colors.grey[300],
          child: Icon(
            Icons.airlines,
            color: hasSelection
                ? Colors.blue
                : Theme.of(context).hintColor.withAlpha(90),
          ),
        ),
        title: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: disabled
                ? Theme.of(context).hintColor.withAlpha(90)
                : hasSelection
                ? Colors.blue
                : Theme.of(context).hintColor,
          ),
        ),
        trailing: Checkbox(
          activeColor: Colors.blue,
          value: hasSelection,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: disabled
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      if (value) {
                        selectedAirlines.value = filteredAirlines.toSet();
                      } else {
                        selectedAirlines.value = {};
                      }
                    });
                  }
                },
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search airlines...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onChanged: (value) => {setState(() {})},
      ),
    );
  }

  Widget _buildHeader(FlightSearchState searchState) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8),
          Text(
            'Select Airline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () => _handleSaved(searchState, context),
            child: Text('Save'),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildShowSingleAirlineToggle(int airlineCount) {
    return TextButton.icon(
      onPressed: () {
        setState(() {
          _filterSingleCarriers = !_filterSingleCarriers;
        });
      },
      icon: Badge(
        label: _filterSingleCarriers ? Text(airlineCount.toString()) : null,
        backgroundColor: _singleCarrierAirlines.isEmpty
            ? Theme.of(context).hintColor.withAlpha(50)
            : Colors.blue,
        offset: Offset(8, -8),
        child: Icon(
          _filterSingleCarriers
              ? Icons.filter_alt_outlined
              : Icons.filter_alt_off_outlined,
          size: 18,
        ),
      ),
      label: IntrinsicWidth(
        child: ListTile(
          title: Text(
            'Single Carriers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _filterSingleCarriers
                  ? Colors.blue
                  : Theme.of(context).hintColor,
            ),
          ),
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: _filterSingleCarriers ? Colors.blue : Colors.grey,
      ),
    );
  }

  void _handleSaved(FlightSearchState searchState, BuildContext context) {
    final currentAirlines = selectedAirlines.value;
    if (currentAirlines.isEmpty) {
      setState(() {
        _errorMessage = 'Must select an airline to save';
      });
      return;
    }

    final airlinesChanged = !setEquals(currentAirlines, _initialAirlines);
    if (!airlinesChanged) {
      Navigator.pop(context);
      return;
    }

    searchState.updateSearch(includedAirlines: currentAirlines.toList());
    Navigator.pop(context);
  }
}
