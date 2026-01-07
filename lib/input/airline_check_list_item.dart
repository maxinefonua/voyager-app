import 'package:flutter/material.dart';
import 'package:voyager/models/airline/airline.dart';

class AirlineCheckListItem extends StatelessWidget {
  final Airline airline;
  final bool isSelected;
  final VoidCallback onChanged;
  const AirlineCheckListItem({
    super.key,
    required this.airline,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 196, 201, 205).withAlpha(35)
              : Theme.of(context).disabledColor.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.airlines,
          size: 20,
          color: isSelected
              ? Colors.blue.withAlpha(200)
              : Theme.of(context).disabledColor.withAlpha(50),
        ),
      ),
      title: Text(
        airline.displayText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).hintColor.withAlpha(200)
              : Theme.of(context).hintColor.withAlpha(80),
        ),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) => onChanged,
        activeColor: Colors.blue,
      ),
      onTap: onChanged,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
