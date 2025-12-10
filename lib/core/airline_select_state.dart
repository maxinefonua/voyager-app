import 'package:flutter/material.dart';
import 'package:voyager/filters/airline_option_list.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineSelectState extends StatefulWidget {
  final Airline? selectedAirline;
  final List<Airline>? enabledAirlines;
  final ValueChanged<Airline?> onSelected;
  const AirlineSelectState({
    super.key,
    required this.selectedAirline,
    required this.enabledAirlines,
    required this.onSelected,
  });

  @override
  State<AirlineSelectState> createState() => _AirlineSelectStateState();
}

class _AirlineSelectStateState extends State<AirlineSelectState> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late Airline? _currentSelection;
  late List<Airline>? _enabledAirlines;
  late bool _showDisabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    _currentSelection = widget.selectedAirline;
    _enabledAirlines = widget.enabledAirlines;
    _showDisabled = false;
  }

  @override
  void didUpdateWidget(AirlineSelectState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAirline != oldWidget.selectedAirline) {
      setState(() {
        _currentSelection = widget.selectedAirline;
      });
    }
    if (widget.enabledAirlines != oldWidget.enabledAirlines) {
      setState(() {
        _enabledAirlines = widget.enabledAirlines;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSelection(Airline? airline) async {
    if (airline == _currentSelection) return;
    setState(() {
      _currentSelection = airline;
    });
    widget.onSelected(airline);
    await Future.delayed(Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final disabledCount = AirlineOptionList.airlineValues
        .where((airline) => !(_enabledAirlines?.contains(airline) ?? true))
        .length;
    return Column(
      children: [
        _buildHeader(disabledCount),
        _buildSearchBar(),
        Divider(height: 0),
        Expanded(
          child: AirlineOptionList(
            selectedAirline: _currentSelection,
            enabledAirlines: _enabledAirlines,
            onAirlineSelected: _handleSelection,
            searchQuery: _searchController.text.toLowerCase(),
            showDisabled: _showDisabled,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search airlines...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildHeader(int disabledCount) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
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
          if (disabledCount > 0) ...[
            Spacer(),
            _buildShowDisabledToggle(disabledCount),
            SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildShowDisabledToggle(int disabledCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Badge(
        label: Text(
          disabledCount.toString(),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        isLabelVisible: disabledCount > 0,
        child: TextButton.icon(
          onPressed: () {
            setState(() {
              _showDisabled = !_showDisabled;
            });
          },
          icon: Icon(
            _showDisabled
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
          ),
          label: Text('Filtered'),
          style: TextButton.styleFrom(
            foregroundColor: _showDisabled ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
