import 'package:flutter/material.dart';
import 'package:voyager/navigation/responsive_appbar.dart';
import 'package:voyager/screens/home_screen.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: ResponsiveAppbar(isMobile: false, selectedTitle: 'Voyager'),
          body: HomeAppBody(),
        );
      },
    );
  }
}
