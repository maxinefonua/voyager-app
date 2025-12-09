import 'package:flutter/material.dart';

class ExpansionState extends ChangeNotifier {
  final ValueNotifier<bool> _collapseDepartures = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _collapseReturns = ValueNotifier<bool>(false);

  ValueNotifier<bool> get collapseDeparturesRequested => _collapseDepartures;
  ValueNotifier<bool> get collapseReturnsRequested => _collapseReturns;

  void collapseDepartures() {
    _collapseDepartures.value = true;
    Future.delayed(Duration(milliseconds: 100), () {
      _collapseDepartures.value = false;
    });
    notifyListeners();
  }

  void collapseReturns() {
    _collapseReturns.value = true;
    Future.delayed(Duration(milliseconds: 100), () {
      _collapseReturns.value = false;
    });
    notifyListeners();
  }
}
