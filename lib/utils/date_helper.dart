import 'package:intl/intl.dart';

import './app_constants.dart';

class DateHelper {
  // Format date for display
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  // Format time for display
  static String formatTime(String time) {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final dateTime = DateTime(2023, 1, 1, hour, minute);
      return DateFormat(AppConstants.displayTimeFormat).format(dateTime);
    } catch (e) {
      return time;
    }
  }

  // Format date and time together
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(
            '${AppConstants.displayDateFormat} ${AppConstants.displayTimeFormat}')
        .format(dateTime);
  }

  // Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  // Get day of week
  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  // Parse date string
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get date range display
  static String getDateRangeDisplay(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return formatDate(start);
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  // Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // Get business days between two dates (excluding weekends)
  static int businessDaysBetween(DateTime start, DateTime end) {
    int count = 0;
    DateTime current = start;

    while (current.isBefore(end) || isSameDay(current, end)) {
      if (current.weekday < 6) {
        // Monday = 1, Sunday = 7
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }

  // Get next business day
  static DateTime getNextBusinessDay(DateTime date) {
    DateTime nextDay = date.add(const Duration(days: 1));
    while (nextDay.weekday > 5) {
      // Weekend
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return nextDay;
  }

  // Format duration in minutes to readable format
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  // Get time slots for a given duration
  static List<String> getTimeSlots({
    String startTime = '08:00',
    String endTime = '18:00',
    int intervalMinutes = 30,
  }) {
    final slots = <String>[];

    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      int currentHour = int.parse(startParts[0]);
      int currentMinute = int.parse(startParts[1]);

      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      while (currentHour < endHour ||
          (currentHour == endHour && currentMinute <= endMinute)) {
        final timeString =
            '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
        slots.add(timeString);

        currentMinute += intervalMinutes;
        if (currentMinute >= 60) {
          currentHour += currentMinute ~/ 60;
          currentMinute = currentMinute % 60;
        }
      }
    } catch (e) {
      // Return default slots if parsing fails
      return ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'];
    }

    return slots;
  }
}
