abstract class TimezoneService {
  static TimezoneService? _instance;
  static bool _initialized = false;

  // Singleton access
  static TimezoneService get instance {
    if (!_initialized) {
      throw StateError(
        'TimezoneService not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  // Singleton initialization
  static Future<void> initializeService() async {
    if (!_initialized) {
      _instance = createTimezoneService();
      await _instance!.initialize();
      _initialized = true;
    }
  }

  // Private initialization for implementations
  Future<void> initialize();

  DateTime getLocalDateTime(DateTime utcTime, String timezoneId);
  String formatTimeForAPI(DateTime dateTime, String timezoneId);
  String formatTime(DateTime utcTime, String timezoneId);
  String formatDay(DateTime utcTime, String timezoneId);
}

// Factory function - will be implemented by platform files
TimezoneService createTimezoneService() {
  throw StateError('called abstract method createTimezoneService');
}
