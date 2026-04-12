import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/view/navigation/routes.dart";
import "package:helping_hand/view/pages/overview/overview_page.dart";
import "package:helping_hand/view/pages/overview/screens/remotes/remotes_screen.dart";
import "package:helping_hand/view/pages/overview/screens/tiles/tiles_screen.dart";

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.initial.path,
  errorBuilder: (context, state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(AppRoutes.initial.path);
    });

    return Scaffold(
      body: Center(
        child: Text("routing error"),
      ),
    );
  },
  routes: [
    StatefulShellRoute(
      navigatorContainerBuilder: (context, navigationShell, children) {
        return children[navigationShell.currentIndex];
      },
      builder: (context, state, navigationShell) {
        return OverviewPage(
          navigationShell: navigationShell,
        );
      },
      branches: _overviewNavigationBranches.toList(),
    ),
  ],
);

final overviewNavigatorKeys = AppRoutes.overviewRoutes
    .map((_) => GlobalKey<NavigatorState>())
    .toList();

final _overviewNavigationBranches = AppRoutes.overviewRoutes.mapIndexed((
  index,
  route,
) {
  return StatefulShellBranch(
    initialLocation: route.path,
    navigatorKey: overviewNavigatorKeys[index],
    routes: [
      switch (route) {
        OverviewRoute.tiles => GoRoute(
          path: route.path,
          builder: (context, state) {
            return TilesScreen();
          },
        ),
        OverviewRoute.remotes => GoRoute(
          path: route.path,
          builder: (context, state) {
            return RemotesScreen();
          },
        ),
      },
    ],
  );
});

// CustomTransitionPage<dynamic> _slidingSubroute({
//   required GoRouterState state,
//   required Widget child,
// }) {
//   return CustomTransitionPage(
//     key: state.pageKey,
//     child: child,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       const begin = Offset(1.0, 0.0); // slide from right
//       const end = Offset.zero;
//       const curve = Curves.easeInOut;

//       final tween = Tween(
//         begin: begin,
//         end: end,
//       ).chain(CurveTween(curve: curve));

//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }
