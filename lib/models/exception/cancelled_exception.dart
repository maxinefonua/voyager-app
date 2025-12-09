class CancelledException implements Exception {
  final String message;

  const CancelledException([this.message = 'Operation cancelled']);

  @override
  String toString() => 'CancelledException: $message';
}
