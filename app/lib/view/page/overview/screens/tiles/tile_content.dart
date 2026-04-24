import "package:flutter/material.dart";
import "package:helping_hand/static/styles.dart";

class TileContent extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onClick;
  final Widget child;

  const TileContent({
    super.key,
    required this.title,
    required this.color,
    this.onClick,
    required this.child,
  });

  factory TileContent.loading({
    required String title,
    VoidCallback? onClick,
  }) {
    return TileContent(
      title: title,
      color: Styles.colorOffline,
      onClick: onClick,
      child: CircularProgressIndicator(
        color: Styles.colorSecondary,
      ),
    );
  }

  factory TileContent.icon({
    required String title,
    required IconData iconData,
    required Color color,
    VoidCallback? onClick,
  }) {
    return TileContent(
      title: title,
      color: color,
      onClick: onClick,
      child: Icon(iconData),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO tile content
    return Container(
      child: null,
    );
  }
}
