class Folder {
  final String id;
  final String name;

  // TODO (late) perisisted icons list and serialization
  // final String icon;

  Folder({
    required this.id,
    required this.name,
  });

  Folder.fromData({
    required this.id,
    required this.name,
  });
}
