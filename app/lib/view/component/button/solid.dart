import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/button/plain.dart";

class PlainSolidButton extends PlainButton {
  const PlainSolidButton({
    super.key,
    required super.child,
    required super.onPressed,
    required super.foregroundColor,
    required super.backgroundColor,
    super.enabled,
    super.leading,
  }) : super(
         borderColor: backgroundColor,
       );
}

class SolidButtonPrimary extends PlainSolidButton {
  const SolidButtonPrimary({
    super.key,
    required super.child,
    required super.onPressed,
    super.enabled,
    super.leading,
  }) : super(
         foregroundColor: Styles.colorSecondary,
         backgroundColor: Styles.colorPrimary,
       );
}

class SolidButtonSecondary extends PlainSolidButton {
  const SolidButtonSecondary({
    super.key,
    required super.child,
    required super.onPressed,
    super.enabled,
    super.leading,
  }) : super(
         foregroundColor: Styles.colorPrimary,
         backgroundColor: Styles.colorSecondary,
       );
}
