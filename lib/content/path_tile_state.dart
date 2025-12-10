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
  final VoidCallback? onExpanded;
  final bool isDepartureTile;
  final double height;
  final bool isEnabled;
  final bool isLast;
  const PathTile({
    super.key,
    required this.localizedFlights,
    required this.airportMap,
    required this.timezoneService,
    required this.pathDisplay,
    required this.subtitle,
    required this.onExpanded,
    required this.initiallyExpanded,
    required this.height,
    required this.isDepartureTile,
    required this.isEnabled,
    required this.isLast,
  });

  @override
  State<PathTile> createState() => _PathTileState();
}

class _PathTileState extends State<PathTile>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late bool _isExpanded;
  late VoidCallback? _onExpanded;
  late final ScrollController _scrollController;
  late ValueNotifier<bool> _collapseNotifier;
  late ExpansibleController _expansionController;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isEnabled ? widget.initiallyExpanded : false;
    _onExpanded = widget.onExpanded;
    _scrollController = ScrollController();
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
    _scrollController.dispose();
    _collapseNotifier.removeListener(_onCollapseRequested);
    super.dispose();
  }

  void _toggleExpansion(bool expanded) {
    if (!widget.isEnabled) {
      if (_isExpanded) {
        setState(() {
          _isExpanded = false;
        });
        _expansionController.collapse();
      }
      return;
    }

    setState(() {
      _isExpanded = expanded;
    });
    if (expanded) {
      _expansionController.expand();
      Future.delayed(const Duration(milliseconds: 350), () {
        if (_onExpanded != null) {
          _onExpanded!();
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

    return ExpansionTile(
      shape: Border(),
      collapsedShape: BoxBorder.fromLTRB(
        bottom: BorderSide(width: 1, color: Theme.of(context).dividerColor),
      ),
      visualDensity: VisualDensity(vertical: -4),
      childrenPadding: EdgeInsets.zero, // Remove children padding
      controller: _expansionController,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: _toggleExpansion,
      collapsedBackgroundColor: widget.isEnabled
          ? Theme.of(context).listTileTheme.tileColor
          : null,
      clipBehavior: Clip.none,
      enabled: widget.isEnabled,
      title: Text(widget.pathDisplay),
      subtitle: Text(widget.subtitle),
      children: widget.isLast
          ? [
              SizedBox(
                height: widget.height - calculatedHeaderHeight,
                child: _buildFlightPathList(),
              ),
            ]
          : [
              SizedBox(
                height: widget.height - 1.75 * calculatedHeaderHeight,
                child: _buildFlightPathList(),
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

  ListView _buildFlightPathList() {
    return ListView.builder(
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
