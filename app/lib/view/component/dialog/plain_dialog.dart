import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/static/styles.dart";

typedef ModalCallback = Future<bool> Function();
typedef ModalCallbackVal<T> = Future<bool> Function(T);

VoidCallback popModalOnPressed(
  BuildContext context,
  ModalCallback? onPressed,
) {
  return () async {
    final shouldPop = await onPressed?.call() ?? true;
    if (shouldPop) {
      if (context.mounted) {
        context.pop();
      }
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
      backgroundColor: Styles.colorSecondary,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return IntrinsicWidth(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.8,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: body,
                    ),
                  ),
                  actions,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
