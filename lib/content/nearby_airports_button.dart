import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyager/core/nearby_include_state.dart';
import 'package:voyager/services/country_service.dart';

class NearbyAirportsButton extends StatelessWidget {
  final bool isDeparture;
  final CountryService countryService;
  const NearbyAirportsButton({
    super.key,
    required this.isDeparture,
    required this.countryService,
  });

  @override
  Widget build(BuildContext context) {
    final countryService = context.read<CountryService>();
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      elevation: 1,
      backgroundColor: isDarkMode
          ? Colors.grey[50]
          : Theme.of(context).cardColor,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          constraints: BoxConstraints(
            maxWidth: 800,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
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
          children: [
            TextSpan(
              text: 'ⓘ',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.blue),
            ),
            TextSpan(
              text: ' Nearby Airports',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
