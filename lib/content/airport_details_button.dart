import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/nearby_include_state.dart';
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
    final countryService = context.read<CountryService>();
    return InputChip(
      elevation: 1,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: NearbyIncludeState(
              countryService: countryService,
              isDeparture: isDeparture,
            ),
          ),
        );
      },
      label: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            TextSpan(
              text: 'ⓘ',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
            TextSpan(
              text: ' Nearby Airports',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      selectedColor: Colors.blue[50],
      shape: StadiumBorder(side: BorderSide(color: Colors.grey[300]!)),
    );
  }
}
