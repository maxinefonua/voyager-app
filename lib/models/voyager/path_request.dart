import 'package:equatable/equatable.dart';
import 'package:voyager/models/airline/airline.dart';

class PathRequest extends Equatable {
  final List<String> originList;
  final List<String> destinationList;
  final List<Airline> includedAirlines;
  final String timezoneId;
  final DateTime startTime;

  const PathRequest({
    required this.originList,
    required this.destinationList,
    required this.includedAirlines,
    required this.timezoneId,
    required this.startTime,
  });

  @override
  List<Object?> get props => [
    [...originList]..sort(),
    [...destinationList]..sort(),
    [...includedAirlines.map((value) => value.name)]..sort(),
    timezoneId,
    startTime,
  ];
}
