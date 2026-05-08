sealed class AppRoutes {
  static final initial = tiles;

  static final tiles = RootRoute();
  static final remotes = SubRoute(tiles, "remotes");
  static final settings = SubRoute(tiles, "settings");
}

sealed class AppRoute {
  static const separator = "/";
  static const parameter = ":";

  final String path;

  const AppRoute(this.path);
}

class RootRoute extends AppRoute {
  const RootRoute() : super("/");
}

class SubRoute extends AppRoute {
  final AppRoute parent;
  final String relativePath;

  SubRoute(this.parent, this.relativePath)
    : super(
        "${parent.path}${parent.path.endsWith(AppRoute.separator) ? "" : AppRoute.separator}$relativePath",
      );
}
