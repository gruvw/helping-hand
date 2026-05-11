import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/dialog/cancel_dialog.dart";
import "package:helping_hand/view/component/dialog/plain_dialog.dart";
import "package:helping_hand/view/component/structure/text_input.dart";

class AsyncTextDialog extends HookWidget {
  final String title;
  final String? placeholder;
  final String? initialValue;
  final ValidationFunction<String>? validation;
  final ModalCallback? onCancel;
  final FutureValidationFunction<String> onSubmit;
  final String? inputLabel;
  final String? submitText;
  final String? cancelText;
  final TextCapitalization? capitalization;
  final bool wrap;

  const AsyncTextDialog({
    super.key,
    required this.title,
    required this.onSubmit,
    this.validation,
    this.placeholder,
    this.initialValue,
    this.onCancel,
    this.inputLabel,
    this.submitText,
    this.cancelText,
    this.capitalization,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(
      text: initialValue,
    );

    useListenable(textController);

    // validation
    final validationResultState = useState<ValidationResult?>(null);
    final validationResult =
        validationResultState.value ??
        (validation?.call(textController.text) ?? ValidResult());

    final isSubmitValidatingState = useState(false);
    final isSubmitValidatedState = useState(false);

    final submitValidationIndicator = Container(
      padding: EdgeInsets.only(top: 11),
      child: SizedBox(
        width: 20,
        height: 20,
        child: isSubmitValidatingState.value
            ? CircularProgressIndicator(
                color: Styles.colorPrimary,
                padding: EdgeInsets.all(2),
              )
            : isSubmitValidatedState.value
            ? Icon(
                validationResult.isValid
                    ? Styles.iconSuccess
                    : Styles.iconError,
                color: validationResult.isValid
                    ? Styles.colorSuccess
                    : Styles.colorDanger,
                size: 25,
              )
            : SizedBox(),
      ),
    );

    Future<bool> submit() async {
      final text = textController.text;
      if (text.isEmpty ||
          isSubmitValidatingState.value ||
          !validationResult.isValid) {
        return false;
      }

      if (context.mounted) {
        isSubmitValidatingState.value = true;
      }

      final result = await onSubmit.call(text);

      if (context.mounted) {
        validationResultState.value = result;
        isSubmitValidatedState.value = true;
        isSubmitValidatingState.value = false;
      }

      return result.isValid;
    }

    return CancelDialog(
      title: title,
      cancelText: cancelText,
      confirmedText: submitText,
      confirmEnabled:
          textController.text.isNotEmpty &&
          validationResult.isValid &&
          !isSubmitValidatingState.value &&
          !isSubmitValidatedState.value,
      onCancel: onCancel,
      onConfirm: submit,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextInput(
              autoFocus: true,
              wrap: wrap,
              controller: textController,
              placeholder: placeholder,
              label: inputLabel,
              errorText: validationResultState.value?.errorMessage,
              capitalization: capitalization,
              onSubmitted: (_) async {
                final shouldPop = await submit();
                if (shouldPop && context.mounted) {
                  context.pop();
                }
              },
              onChanged: (_) {
                if (context.mounted) {
                  isSubmitValidatedState.value = false;
                  validationResultState.value = validation?.call(
                    textController.text,
                  );
                }
              },
            ),
          ),
          if (isSubmitValidatingState.value || isSubmitValidatedState.value)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Gap(5),
                submitValidationIndicator,
              ],
            ),
        ],
      ),
    );
  }
}
