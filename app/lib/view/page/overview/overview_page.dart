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

    final routerPath = router.routerDelegate.state.path;
    final isOnTiles = routerPath == OverviewRoute.tiles.path;

    final appBar = AppBar(
      title: Text(Values.applicationTitle),
      backgroundColor: Styles.colorPrimary,
      foregroundColor: Styles.colorSecondary,
      leading: isOnTiles
          ? null
          : IconButton(
              onPressed: () {
                final subState = subNavigatorKey.currentState;
                if (subState == null || !subState.canPop()) {
                  context.go(AppRoutes.initial.path);
                } else {
                  subState.pop();
                }
              },
              icon: Icon(
                Styles.iconPrevious,
                color: Styles.colorSecondary,
              ),
            ),
      actions: [
        if (routerPath != OverviewRoute.remotes.path)
          PopupMenuButton(
            tooltip: "Edit",
            icon: Icon(
              Styles.iconMore,
              color: Styles.colorSecondary,
            ),
            color: Styles.colorSecondary,
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  context.push(OverviewRoute.remotes.path);
                },
                child: ListTile(
                  leading: Icon(Styles.iconAddTile),
                  title: Text("Remotes"),
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  // TODO new folder logic
                },
                child: ListTile(
                  leading: Icon(Styles.iconAddFolder),
                  title: Text("New Folder"),
                ),
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
