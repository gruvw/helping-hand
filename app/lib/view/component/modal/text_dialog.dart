import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/utils/hooks.dart";
import "package:helping_hand/view/component/modal/cancel_dialog.dart";
import "package:helping_hand/view/component/modal/plain_dialog.dart";
import "package:helping_hand/view/component/structure/text_input.dart";

class TextDialog extends HookWidget {
  final String title;
  final String? placeholder;
  final String? initialValue;
  final ValidationFunction<String>? validation;
  final ModalCallback? onCancel;
  final ModalCallbackVal<String>? onSubmit;
  final String? inputLabel;
  final String? submitText;
  final String? cancelText;
  final TextCapitalization? capitalization;
  final bool wrap;

  const TextDialog({
    super.key,
    required this.title,
    this.placeholder,
    this.initialValue,
    this.validation,
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
    useListener(() {
      validationError.value = validation?.call(offlineNameController.text);
    }, [offlineNameController]);

    return CancelDialog(
      title: title,
      cancelText: cancelText,
      confirmedText: submitText,
      confirmEnabled: validationError.value?.isValid,
      onCancel: onCancel,
      onConfirm: () {
        // no need to update validation here as Confirm is disabled while content not valid
        return onSubmit?.call(offlineNameController.text);
      },
      body: TextInput(
        autoFocus: true,
        wrap: wrap,
        controller: offlineNameController,
        placeholder: placeholder,
        label: inputLabel,
        errorText: validationError.value?.errorMessage,
        capitalization: capitalization,
      ),
    );
  }
}
