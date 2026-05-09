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

  static const borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: Colors.blue.shade700,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
