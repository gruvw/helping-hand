sealed class AppRoutes {
  static final initial = OverviewRoute.tiles;

  static final overviewRoutes = OverviewRoute.values;
}

sealed class AppRoute {
  static const separator = "/";
  static const parameter = ":";

  String get path;
}

enum OverviewRoute implements AppRoute {
  tiles("${AppRoute.separator}tiles"),
  remotes("${AppRoute.separator}remotes"),
  ;

  @override
  final String path;

  const OverviewRoute(this.path);
}

// class CategoryRoute implements AppRoute {
//   static const pathParameter = "category";
//   static const favoritesCategory = "favorites";

//   @override
//   final String path = "${AppRoute.parameter}$pathParameter";

//   CategoryRoute._();
// }
