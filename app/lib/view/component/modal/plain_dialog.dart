import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/static/styles.dart";

typedef ModalCallback = bool? Function();
typedef ModalCallbackVal<T> = bool? Function(T);

VoidCallback popModalOnPressed(
  BuildContext context,
  ModalCallback? onPressed,
) {
  return () {
    // pop by default if null is returned
    final shouldPop = onPressed?.call() ?? true;
    if (shouldPop) {
      context.pop();
    }
  };
}

class PlainDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget actions;

  const PlainDialog({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 3,
          color: Styles.colorPrimary,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(12),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: body,
              ),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}
