import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/button/plain.dart";

class PlainOutlinedButton extends PlainButton {
  const PlainOutlinedButton({
    super.key,
    required super.child,
    required super.foregroundColor,
    required super.backgroundColor,
    super.onPressed,
    super.leading,
    super.enabled,
  }) : super(
         borderColor: foregroundColor,
       );
}

class OutlinedButtonPrimary extends PlainOutlinedButton {
  const OutlinedButtonPrimary({
    super.key,
    required super.child,
    super.onPressed,
    super.leading,
    super.enabled,
  }) : super(
         foregroundColor: Styles.colorPrimary,
         backgroundColor: Styles.colorSecondary,
       );
}

class OutlinedButtonSecondary extends PlainOutlinedButton {
  const OutlinedButtonSecondary({
    super.key,
    required super.child,
    super.onPressed,
    super.leading,
    super.enabled,
  }) : super(
         foregroundColor: Styles.colorSecondary,
         backgroundColor: Styles.colorPrimary,
       );
}
