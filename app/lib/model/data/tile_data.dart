class TileData {
  static final idSeparator = ":";

  final String? parentId;
  final String id;
  final int position;

  TileData({
    required this.parentId,
    required this.id,
    required this.position,
  });

  TileData.fromData({
    required this.parentId,
    required this.id,
    required this.position,
  });
}
