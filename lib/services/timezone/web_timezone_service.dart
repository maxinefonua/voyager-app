import 'package:flutter/cupertino.dart';
import 'package:timezone/browser.dart' as tz;
import 'package:voyager/services/timezone/timezone_service_interface.dart';
import 'package:voyager/utils/date_time_extensions.dart';
import 'package:voyager/utils/format.dart';

class WebTimezoneService implements TimezoneService {
  bool _initialized = false;
  @override
  Future<void> initialize() async {
    if (!_initialized) {
      debugPrint('🌐 Initializing WebTimezoneService...');

      try {
        await tz.initializeTimeZone('assets/packages/timezone/data/latest.tzf');
        debugPrint('🎯 Timezone initialized from network');
      } catch (e) {
        debugPrint(e.toString());
        debugPrintStack();
        rethrow;
      }

      _initialized = true;
    }
  }

  @override
  DateTime getLocalDateTime(DateTime utcTime, String timezoneId) {
    final location = tz.getLocation(timezoneId);
    return tz.TZDateTime.from(utcTime, location);
  }

  @override
  String formatTimeForAPI(DateTime dateTime, String timezoneId) {
    final location = tz.getLocation(timezoneId);
    final localDateTime = tz.TZDateTime.from(
      DateTime(dateTime.year, dateTime.month, dateTime.day),
      location,
    );
    return Uri.encodeComponent(localDateTime.toIso8601String());
  }

  @override
  String formatTime(DateTime utcTime, String timezoneId) {
    final localDateTime = getLocalDateTime(utcTime, timezoneId);

    int hour = localDateTime.hour;
    int minute = localDateTime.minute;

    String period = hour < 12 ? 'AM' : 'PM';

    // Convert to 12-hour format
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;

    // Format minute with leading zero if needed
    String minuteStr = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteStr $period';
  }

  @override
  String formatDay(DateTime utcTime, String timezoneId) {
    final localDateTime = getLocalDateTime(utcTime, timezoneId);

    final weekday = getWeekday(localDateTime.weekday);
    String monthAbbreviation = localDateTime.monthAbbreviation;

    return '$weekday, $monthAbbreviation ${localDateTime.day}';
  }
}

// Factory function implementation
TimezoneService createTimezoneService() => WebTimezoneService();
