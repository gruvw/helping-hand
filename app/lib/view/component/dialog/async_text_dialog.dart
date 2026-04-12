import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/dialog/cancel_dialog.dart";
import "package:helping_hand/view/component/dialog/plain_dialog.dart";
import "package:helping_hand/view/component/structure/text_input.dart";

class AsyncTextDialog extends HookWidget {
  final String title;
  final String? placeholder;
  final String? initialValue;
  final ValidationFunction<String> validation;
  final ModalCallback? onCancel;
  final ModalCallbackVal<String>? onSubmit;
  final String? inputLabel;
  final String? submitText;
  final String? cancelText;
  final TextCapitalization? capitalization;
  final bool wrap;

  const AsyncTextDialog({
    super.key,
    required this.title,
    required this.validation,
    this.placeholder,
    this.initialValue,
    this.onCancel,
    this.onSubmit,
    this.inputLabel,
    this.submitText,
    this.cancelText,
    this.capitalization,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final offlineNameController = useTextEditingController(
      text: initialValue,
    );

    // validation
    final validationError = useState<ValidationResult?>(null);
    final isValidating = useState(false);
    final generation = useRef(0);

    final validationValue = validationError.value;
    final validationIndicator = Container(
      padding: EdgeInsets.only(top: 11),
      child: SizedBox(
        width: 20,
        height: 20,
        child: isValidating.value
            ? CircularProgressIndicator(
                color: Styles.colorPrimary,
                padding: EdgeInsets.all(2),
              )
            : validationValue == null
            ? SizedBox()
            : Icon(
                validationValue.isValid ? Styles.iconValid : Styles.iconInvalid,
                color: validationValue.isValid
                    ? Styles.colorSuccess
                    : Styles.colorDanger,
                size: 25,
              ),
      ),
    );

    return CancelDialog(
      title: title,
      cancelText: cancelText,
      confirmedText: submitText,
      confirmEnabled: true,
      onCancel: onCancel,
      onConfirm: () async {
        final text = offlineNameController.text;
        if (text.isEmpty) {
          return false;
        }

        final currentGen = ++generation.value;
        validationError.value = null;
        isValidating.value = true;
        final result = await validation.call(text);
        if (currentGen == generation.value) {
          validationError.value = result;
          isValidating.value = false;
          if (result.isValid) {
            return onSubmit?.call(offlineNameController.text);
          } else {
            return false;
          }
        } else {
          return false;
        }
      },
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextInput(
              autoFocus: true,
              wrap: wrap,
              controller: offlineNameController,
              placeholder: placeholder,
              label: inputLabel,
              errorText: validationError.value?.errorMessage,
              capitalization: capitalization,
            ),
          ),
          Gap(5),
          validationIndicator,
        ],
      ),
    );
  }
}
