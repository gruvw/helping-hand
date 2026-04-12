import "package:flutter/material.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/button/solid.dart";
import "package:helping_hand/view/component/dialog/plain_dialog.dart";

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final ModalCallback? onPressed;
  final String? confirmedText;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.body,
    this.onPressed,
    this.confirmedText,
  });

  @override
  Widget build(BuildContext context) {
    return PlainDialog(
      title: title,
      body: body,
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SolidButtonPrimary(
            onPressed: popModalOnPressed(context, onPressed),
            child: Text(
              confirmedText ?? "Confirm",
              style: Styles.textNormal.apply(
                color: Styles.colorSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
