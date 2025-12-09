import 'package:flutter/material.dart';

// Public base component
class BaseDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final DateTimeRange? selectedDateRange;
  final DateTime firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool isRange;
  final VoidCallback onTap;
  final String? customDisplayText; // Add this

  const BaseDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.selectedDateRange,
    required this.firstDate,
    required this.lastDate,
    required this.enabled,
    required this.isRange,
    required this.onTap,
    this.customDisplayText, // Optional custom text
  });

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${weekdays[date.weekday - 1]}, $month/$day';
  }

  String _getDisplayText() {
    // Use custom display text if provided
    if (customDisplayText != null) {
      return customDisplayText!;
    }

    if (isRange) {
      if (selectedDateRange != null) {
        return '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}';
      }
      return 'Select date range';
    } else {
      if (selectedDate != null) {
        return _formatDate(selectedDate!);
      }
      return 'Select date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(text: _getDisplayText()),
      readOnly: true,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.date_range),
          onPressed: enabled ? onTap : null,
        ),
        hintText: isRange ? 'Tap to select date range' : 'Tap to select date',
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
