import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/button/plain.dart";

class PlainOutlinedButton extends PlainButton {
  const PlainOutlinedButton({
    super.key,
    super.onPressed,
    super.onLongPress,
    super.leading,
    super.enabled,
    required super.foregroundColor,
    required super.backgroundColor,
    required super.child,
  }) : super(
         borderColor: foregroundColor,
       );
}

class OutlinedButtonPrimary extends PlainOutlinedButton {
  const OutlinedButtonPrimary({
    super.key,
    super.onPressed,
    super.onLongPress,
    super.leading,
    super.enabled,
    required super.child,
  }) : super(
         foregroundColor: Styles.colorPrimary,
         backgroundColor: Styles.colorSecondary,
       );
}

class OutlinedButtonSecondary extends PlainOutlinedButton {
  const OutlinedButtonSecondary({
    super.key,
    super.onPressed,
    super.onLongPress,
    super.leading,
    super.enabled,
    required super.child,
  }) : super(
         foregroundColor: Styles.colorSecondary,
         backgroundColor: Styles.colorPrimary,
       );
}
