import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/view/navigation/routes.dart";
import "package:helping_hand/view/page/remotes/remotes_page.dart";
import "package:helping_hand/view/page/tiles/tiles_page.dart";

final router = GoRouter(
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
    GoRoute(
      path: AppRoutes.tiles.path,
      builder: (context, state) {
        return TilesPage();
      },
      routes: [
        GoRoute(
          path: AppRoutes.remotes.relativePath,
          builder: (context, state) {
            return RemotesPage();
          },
        ),
        GoRoute(
          path: AppRoutes.settings.relativePath,
          builder: (context, state) {
            // TODO settings page
            throw UnimplementedError();
          },
        ),
      ],
    ),
  ],
);

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
