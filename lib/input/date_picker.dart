// Single Date Picker
import 'package:flutter/material.dart';
import 'date_picker_components.dart'; // Import the base class

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final DateTime firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool enabled;

  const DatePickerField({
    super.key,
    required this.label,
    required this.onDateSelected,
    required this.selectedDate,
    required this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDatePickerField(
      // Use public base class
      label: label,
      selectedDate: selectedDate,
      selectedDateRange: null,
      firstDate: firstDate,
      lastDate: lastDate,
      enabled: enabled,
      isRange: false,
      onTap: () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime effectiveLastDate =
        lastDate ?? firstDate.add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: effectiveLastDate,
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}

class DateRangePickerField extends StatelessWidget {
  final String label;
  final DateTimeRange? selectedDateRange;
  final DateTime? departureDate;
  final DateTime firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTimeRange> onDateRangeSelected;
  final bool enabled;

  const DateRangePickerField({
    super.key,
    required this.label,
    required this.onDateRangeSelected,
    required this.selectedDateRange,
    this.departureDate, // Make it optional
    required this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    String? customDisplayText;

    // Create custom display text if we have departure date but no range
    if (departureDate != null && selectedDateRange == null) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final month = departureDate!.month.toString().padLeft(2, '0');
      final day = departureDate!.day.toString().padLeft(2, '0');
      customDisplayText =
          '${weekdays[departureDate!.weekday - 1]}, $month/$day - Select return date';
    }

    return BaseDatePickerField(
      label: label,
      selectedDate: departureDate, // Pass departure date
      selectedDateRange: selectedDateRange,
      firstDate: firstDate,
      lastDate: lastDate,
      enabled: enabled,
      isRange: true,
      onTap: () => _selectDateRange(context),
      customDisplayText: customDisplayText, // Pass custom text
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime effectiveLastDate =
        lastDate ?? firstDate.add(const Duration(days: 365));

    // Create initial date range using departureDate if available
    DateTimeRange? initialRange = selectedDateRange;

    if (initialRange == null && departureDate != null) {
      initialRange = DateTimeRange(
        start: departureDate!,
        end: departureDate!, // Same as start
      );
    }

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: effectiveLastDate,
      initialDateRange:
          initialRange, // Use initialRange here, not selectedDateRange
    );

    if (picked != null) {
      onDateRangeSelected(picked);
    }
  }
}
