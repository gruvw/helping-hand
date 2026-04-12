import "package:flutter/material.dart";
import "package:helping_hand/static/values.dart";
import "package:helping_hand/view/pages/overview/tiles_area.dart";

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(Values.applicationTitle),
    );

    return Scaffold(
      appBar: appBar,
      body: TilesArea(),
    );
  }
}
