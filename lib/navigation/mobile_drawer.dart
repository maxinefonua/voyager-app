import 'package:flutter/material.dart';
import 'package:voyager/navigation/nav.dart';

class MobileDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;
  const MobileDrawer({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // SizedBox(height: 40),
          ...buildNavItems(context).map((textButton) {
            return ListTile(
              title: textButton.child,
              onTap: () {
                Navigator.pop(context);
                textButton.onPressed!.call();
              },
            );
          }),
        ],
      ),
    );
  }
}
