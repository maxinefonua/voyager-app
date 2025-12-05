import 'package:flutter/material.dart';
import 'package:voyager/screens/about_screen.dart';

void navigateToAbout(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AboutScaffold()),
  );
}

List<TextButton> buildNavItems(BuildContext context) {
  return [
    TextButton(
      onPressed: () => {navigateToAbout(context)},
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      child: Text('About'),
    ),
  ];
}
