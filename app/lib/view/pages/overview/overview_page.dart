import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/static/values.dart";
import "package:helping_hand/view/navigation/router.dart";
import "package:helping_hand/view/navigation/routes.dart";

class OverviewPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const OverviewPage({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final subNavigatorKey = overviewNavigatorKeys[navigationShell.currentIndex];

    final isOnTiles =
        router.routerDelegate.state.path == OverviewRoute.tiles.path;

    final appBar = AppBar(
      title: Text(Values.applicationTitle),
      backgroundColor: Styles.colorForeground,
      foregroundColor: Styles.colorBackground,
      leading: isOnTiles
          ? null
          : IconButton(
              onPressed: () {
                subNavigatorKey.currentState?.maybePop();
              },
              icon: Icon(Styles.iconPrevious),
            ),
      actions: [
        PopupMenuButton(
          tooltip: "Edit",
          icon: Icon(Styles.iconEdit),
          color: Styles.colorBackground,
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () {
                context.push(OverviewRoute.remotes.path);
              },
              child: Text("Remotes"),
            ),
            PopupMenuItem(
              onTap: () {
                // TODO new folder logic
              },
              child: Text("New Folder"),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: navigationShell,
    );
  }
}
