import "package:flutter/material.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";

class TileContent extends StatelessWidget {
  static const borderRadius = 12.0;
  static const foregroundDarkenAmount = 0.75;
  static const selectedBorderWidth = 6.0;

  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Widget child;
  final bool selected;

  const TileContent({
    super.key,
    required this.title,
    this.subtitle,
    required this.color,
    this.onTap,
    this.onDoubleTap,
    required this.child,
    required this.selected,
  });

  factory TileContent.loading({
    required String title,
    required Color color,
    String? subtitle,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    Key? key,
    bool selected = false,
  }) {
    return TileContent(
      key: key,
      title: title,
      subtitle: subtitle,
      color: color,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      selected: selected,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: color.darken(foregroundDarkenAmount),
          ),
        ),
      ),
    );
  }

  factory TileContent.icon({
    required String title,
    String? subtitle,
    required IconData iconData,
    required Color color,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    Key? key,
    bool selected = false,
  }) {
    return TileContent(
      key: key,
      title: title,
      subtitle: subtitle,
      color: color,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      selected: selected,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: Icon(
          key: ValueKey(iconData),
          iconData,
          color: color.darken(foregroundDarkenAmount),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    final text = subtitle == null
        ? Text(
            title,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: color.darken(foregroundDarkenAmount),
              fontWeight: FontWeight.w600,
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: color.darken(foregroundDarkenAmount),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: color.darken(foregroundDarkenAmount),
                ),
              ),
            ],
          );

    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Material(
        type: MaterialType.card,
        animationDuration: const Duration(milliseconds: 100),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: selected
              ? BorderSide(
                  color: Styles.colorOutline,
                  width: selectedBorderWidth,
                )
              : BorderSide(
                  color: color.darken(.2),
                  width: 2,
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(selectedBorderWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: text,
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
