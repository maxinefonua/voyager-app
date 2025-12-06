import 'package:flutter/material.dart';
import 'package:voyager/content/nearby_dialog.dart';
import 'package:voyager/services/country_service.dart';

class AirportDetailsButton extends StatelessWidget {
  final bool isDeparture;
  final CountryService countryService;
  const AirportDetailsButton({
    super.key,
    required this.isDeparture,
    required this.countryService,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => NearbyDialog(
          isDeparture: isDeparture,
          countryService: countryService,
        ),
      ),
      label: Text(
        'ⓘ Details and Nearby Airports',
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.blue[50],
      shape: StadiumBorder(side: BorderSide(color: Colors.grey[300]!)),
    );
  }
}
