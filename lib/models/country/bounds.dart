class Bounds {
  final double west;
  final double south;
  final double east;
  final double north;

  Bounds({
    required this.west,
    required this.south,
    required this.east,
    required this.north,
  });

  factory Bounds.fromJson(List<dynamic> list) {
    if (list.length != 4) {
      throw ArgumentError('Bounds list must contain exactly 4 elements');
    }

    return Bounds(
      west: list[0].toDouble(),
      south: list[1].toDouble(),
      east: list[2].toDouble(),
      north: list[3].toDouble(),
    );
  }
}
