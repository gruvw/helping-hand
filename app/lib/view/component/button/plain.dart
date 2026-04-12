import "package:flutter/material.dart";
import "package:helping_hand/static/styles.dart";

class PlainButton extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final double horizontalPadding;

  const PlainButton({
    super.key,
    required this.child,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    this.leading,
    this.enabled = true,
    this.horizontalPadding = 10,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      // button disabled when onPressed is null
      onPressed: enabled ? (onPressed ?? () {}) : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor, // used for splash color
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: horizontalPadding,
        ),
        backgroundColor: backgroundColor,
        disabledForegroundColor: foregroundColor.withValues(
          alpha: Styles.disabledOpacity,
        ),
        disabledBackgroundColor: backgroundColor.withValues(
          alpha: Styles.disabledOpacity,
        ),
        side: BorderSide(
          width: 2.0,
          style: borderColor == backgroundColor
              ? BorderStyle.none
              : BorderStyle.solid,
          color: enabled
              ? borderColor
              : borderColor.withValues(alpha: Styles.disabledOpacity),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
        // reset material padding and boxes
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null)
            Padding(
              padding: const EdgeInsets.only(
                right: 8.0,
              ),
              child: leading!,
            ),
          child,
        ],
      ),
    );
  }
}
