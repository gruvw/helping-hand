import "package:flutter/material.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/button/outlined.dart";
import "package:helping_hand/view/component/button/solid.dart";
import "package:helping_hand/view/component/dialog/plain_dialog.dart";

class CancelDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final bool danger;
  final ModalCallback? onCancel;
  final ModalCallback? onConfirm;
  final String? confirmedText;
  final String? cancelText;
  final bool confirmEnabled;

  const CancelDialog({
    super.key,
    required this.title,
    required this.body,
    this.danger = false,
    bool? confirmEnabled,
    this.onCancel,
    this.onConfirm,
    this.confirmedText,
    this.cancelText,
  }) : confirmEnabled = confirmEnabled ?? true;

  @override
  Widget build(BuildContext context) {
    const confirmDefault = "Confirm";

    return PlainDialog(
      title: title,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: body,
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButtonPrimary(
            onPressed: popModalOnPressed(context, onCancel),
            child: Text(
              cancelText ?? "Cancel",
              style: Styles.textNormal,
            ),
          ),
          if (onConfirm != null)
            if (danger)
              PlainSolidButton(
                onPressed: popModalOnPressed(context, onConfirm),
                foregroundColor: Styles.colorSecondary,
                backgroundColor: Styles.colorDanger,
                child: Text(
                  confirmedText ?? confirmDefault,
                  style: Styles.textNormal.apply(
                    color: Styles.colorSecondary,
                  ),
                ),
              )
            else
              SolidButtonPrimary(
                onPressed: popModalOnPressed(context, onConfirm),
                enabled: confirmEnabled,
                child: Text(
                  confirmedText ?? confirmDefault,
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
