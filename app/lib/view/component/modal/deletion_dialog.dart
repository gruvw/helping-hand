import "package:flutter/material.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/modal/cancel_dialog.dart";
import "package:helping_hand/view/component/modal/plain_dialog.dart";

class DeletionDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? target;
  final ModalCallback? onDelete;

  const DeletionDialog({
    super.key,
    this.onDelete,
    this.target,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return CancelDialog(
      title: title,
      confirmedText: "Delete",
      danger: true,
      body: Column(
        children: [
          Text(content, style: Styles.textNormal),
          if (target != null)
            Text(
              target!,
              textAlign: TextAlign.center,
              style: Styles.textNormal.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      onConfirm: onDelete,
    );
  }
}
