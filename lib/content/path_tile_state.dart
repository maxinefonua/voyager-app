import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/content/flight_path_card.dart';
import 'package:voyager/controllers/expansion_state_controller.dart';
import 'package:voyager/models/airport/airport.dart';
import 'package:voyager/models/flight/flight_detailed.dart';
import 'package:voyager/services/timezone/timezone_service_interface.dart';

class PathTile extends StatefulWidget {
  final List<List<FlightDetailed>> localizedFlights;
  final Map<String, Airport> airportMap;
  final TimezoneService timezoneService;
  final String pathDisplay;
  final String subtitle;
  final bool initiallyExpanded;
  final bool constrainList;
  final bool isDepartureTile;
  final double? height;
  final bool isEnabled;
  const PathTile({
    super.key,
    required this.localizedFlights,
    required this.airportMap,
    required this.timezoneService,
    required this.pathDisplay,
    required this.subtitle,
    required this.initiallyExpanded,
    required this.constrainList,
    this.height,
    required this.isDepartureTile,
    required this.isEnabled,
  });

  @override
  State<PathTile> createState() => _PathTileState();
}

class _PathTileState extends State<PathTile>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late bool _isExpanded;
  late final ScrollController _scrollController;
  late ValueNotifier<bool> _collapseNotifier;
  late ExpansibleController _expansionController; // Add this

  PageStorageKey get _listKey =>
      PageStorageKey('path_tile_${widget.pathDisplay}');

  @override
  void initState() {
    super.initState();
    debugPrint(
      'Initializing PathTile with ${widget.localizedFlights.length} flight paths',
    );
    _isExpanded = widget.initiallyExpanded;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _expansionController = ExpansibleController(); // Initialize
  }

  @override
  void didUpdateWidget(PathTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update expanded state if parent changed it
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded) {
      setState(() {
        _isExpanded = widget.initiallyExpanded;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final expansionState = context.read<ExpansionState>();

    // Get the appropriate notifier based on tile type
    _collapseNotifier = widget.isDepartureTile
        ? expansionState.collapseDeparturesRequested
        : expansionState.collapseReturnsRequested;

    // Listen to the notifier
    _collapseNotifier.addListener(_onCollapseRequested);
  }

  void _onCollapseRequested() {
    if (_collapseNotifier.value && mounted && widget.isEnabled) {
      setState(() {
        _isExpanded = false;
      });
      _expansionController.collapse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseNotifier.removeListener(_onCollapseRequested);
    super.dispose();
  }

  void _onScroll() {
    if (!_isExpanded) return;

    final threshold = 50.0;
    final position = _scrollController.position;

    // Optional: Show a snackbar or hint when near bottom
    if (position.pixels >= position.maxScrollExtent - threshold) {
      // Optional: Show a hint that releasing will collapse
      Future.microtask(() {
        if (mounted && widget.isEnabled && _isExpanded) {
          // You could show a snackbar or other UI hint here
          setState(() {
            _isExpanded = false;
          });
          _expansionController.collapse();
        }
      });
    }
  }

  void _toggleExpansion(bool expanded) {
    setState(() {
      _isExpanded = expanded;
    });

    if (expanded) {
      _expansionController.expand();
      // Scroll to top when expanding
      Future.microtask(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } else {
      _expansionController.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Calculate header height based on content
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium ?? TextStyle(fontSize: 16);
    final subtitleStyle = textTheme.bodySmall ?? TextStyle(fontSize: 14);

    final titleHeight = _calculateTextHeight(
      widget.pathDisplay,
      titleStyle,
      MediaQuery.of(context).size.width - 32,
    );
    final subtitleHeight = widget.subtitle.isNotEmpty
        ? _calculateTextHeight(
            widget.subtitle,
            subtitleStyle,
            MediaQuery.of(context).size.width - 32,
          )
        : 0;
    final paddingHeight = 24;
    final calculatedHeaderHeight = titleHeight + subtitleHeight + paddingHeight;

    debugPrint('build expansiontile with _isExpanded: $_isExpanded');
    return ExpansionTile(
      controller: _expansionController,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: _toggleExpansion,
      collapsedBackgroundColor: widget.isEnabled ? Colors.white : null,
      clipBehavior: Clip.none,
      enabled: widget.isEnabled,
      title: Text(widget.pathDisplay),
      subtitle: Text(widget.subtitle),
      children: widget.height == null
          ? [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: _buildFlightPathList(_listKey),
              ),
            ]
          : [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.height! - calculatedHeaderHeight,
                ),
                child: _buildFlightPathList(_listKey),
              ),
            ],
    );
  }

  double _calculateTextHeight(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return textPainter.height;
  }

  ListView _buildFlightPathList(PageStorageKey? key) {
    return ListView.builder(
      key: key,
      shrinkWrap: true,
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.localizedFlights.length,
      itemBuilder: (context, index) {
        final flightPath = widget.localizedFlights[index];
        return FlightPathCard(
          flightPath: flightPath,
          airportMap: widget.airportMap,
        );
      },
    );
  }
}
