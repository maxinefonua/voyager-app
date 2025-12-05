import 'package:flutter/material.dart';
import 'package:voyager/content/collapse_button.dart';
import 'package:voyager/content/load_more_button.dart';

class TabAwareBottomBar extends StatelessWidget {
  final bool isUpdating;

  const TabAwareBottomBar({super.key, required this.isUpdating});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DefaultTabController.of(context),
      builder: (context, child) {
        final tabController = DefaultTabController.of(context);
        final isDeparture = tabController.index == 0;

        return Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(child: LoadMoreButton(isDeparture: isDeparture)),
              SizedBox(width: 8),
              Expanded(child: CollapseButton(isDeparture: isDeparture)),
            ],
          ),
        );
      },
    );
  }
}
