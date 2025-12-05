import 'package:voyager/utils/date_time_extensions.dart';

String formatDate(DateTime date) {
  final weekday = getWeekday(date.weekday);
  return '$weekday, ${date.month}/${date.day}/${date.year}';
}

String formatDay(DateTime localDateTime, String timezoneId) {
  final weekday = getWeekday(localDateTime.weekday);
  String monthAbbreviation = localDateTime.monthAbbreviation;

  return '$weekday, $monthAbbreviation ${localDateTime.day}';
}

String formatTime(DateTime localDateTime) {
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

String formatDistance(double distance) {
  final sb = StringBuffer();
  if (distance > 1000) {
    sb.write((distance / 1000).toStringAsFixed(1));
    sb.write('k ');
  } else {
    sb.write(distance.toStringAsFixed(1));
  }
  sb.write('km');
  return sb.toString();
}

String formatDuration(DateTime start, DateTime end) {
  final duration = end.difference(start);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours == 0) {
    return '${minutes}min';
  } else if (minutes == 0) {
    return '${hours}hr${hours > 1 ? 's' : ''}';
  } else {
    return '${hours}hr${hours > 1 ? 's' : ''} ${minutes}min';
  }
}

String getWeekday(int weekday) {
  switch (weekday) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return '';
  }
}

Duration parseJavaDuration(String javaDuration) {
  final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
  final match = regex.firstMatch(javaDuration);

  if (match == null) {
    throw FormatException('Invalid Java duration format: $javaDuration');
  }

  final hours = int.tryParse(match[1] ?? '0') ?? 0;
  final minutes = int.tryParse(match[2] ?? '0') ?? 0;
  final seconds = int.tryParse(match[3] ?? '0') ?? 0;

  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}
