import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/button/plain.dart";

class PlainSolidButton extends PlainButton {
  const PlainSolidButton({
    super.key,
    super.enabled,
    super.leading,
    required super.foregroundColor,
    required super.backgroundColor,
    required super.onPressed,
    super.onLongPress,
    required super.child,
  }) : super(
         borderColor: backgroundColor,
       );
}

class SolidButtonPrimary extends PlainSolidButton {
  const SolidButtonPrimary({
    super.key,
    super.enabled,
    super.leading,
    required super.onPressed,
    super.onLongPress,
    required super.child,
  }) : super(
         foregroundColor: Styles.colorSecondary,
         backgroundColor: Styles.colorPrimary,
       );
}

class SolidButtonSecondary extends PlainSolidButton {
  const SolidButtonSecondary({
    super.key,
    super.enabled,
    super.leading,
    required super.onPressed,
    super.onLongPress,
    required super.child,
  }) : super(
         foregroundColor: Styles.colorPrimary,
         backgroundColor: Styles.colorSecondary,
       );
}
