import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";

class TextInput extends HookWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? errorText;
  final bool? isContentPrivate;
  final TextCapitalization? capitalization;
  final bool autoFocus;
  final bool wrap;
  final bool displayClearButton;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;

  const TextInput({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.errorText,
    this.isContentPrivate,
    this.onChanged,
    this.onSubmitted,
    this.capitalization,
    this.wrap = false,
    this.autoFocus = false,
    this.displayClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final textController = controller ?? useTextEditingController();
    final focus = useFocusNode();
    useListenable(focus);

    // Used to display (or not) the clear button
    useListenable(textController);
    final isEmpty = textController.text.isEmpty;

    // Used to display (or not) the visibility button
    final isHidden = useState(isContentPrivate);
    final shouldHideText = isHidden.value ?? false;

    // Only display error when field is not empty or not focused
    final hasError = errorText != null && !(focus.hasFocus && isEmpty);

    // Widgets

    final clearButton = IconButton(
      onPressed: () {
        textController.clear();
        onChanged?.call(textController.text);
      },
      color: Styles.colorPrimary,
      icon: const Icon(Styles.iconClear),
      visualDensity: VisualDensity.compact,
    );

    final visibilityButton = IconButton(
      onPressed: () {
        if (context.mounted) {
          isHidden.value = isHidden.value?.nmap((v) => !v);
        }
      },
      color: Styles.colorPrimary,
      icon: Icon(shouldHideText ? Styles.iconHidden : Styles.iconVisible),
      visualDensity: VisualDensity.compact,
    );

    const border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Styles.colorPrimary,
        width: 2,
      ),
    );

    const errorBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Styles.colorDanger,
        width: 2,
      ),
    );

    final displayClearButton = this.displayClearButton && !isEmpty;
    final displayVisibilityButton = isContentPrivate != null;

    return TextField(
      focusNode: focus,
      textCapitalization: capitalization ?? TextCapitalization.none,
      autofocus: autoFocus,
      controller: textController,
      obscureText: shouldHideText,
      enableSuggestions: !shouldHideText,
      autocorrect: !shouldHideText,
      style: Styles.textNormal,
      cursorColor: Styles.colorPrimary,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: wrap ? null : 1,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 10,
        ),
        errorMaxLines: 10,
        hintText: placeholder,
        labelText: label,
        errorText: hasError ? errorText : null,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        focusColor: Styles.colorPrimary,
        labelStyle: Styles.textNormal.apply(
          color: Styles.colorHint,
        ),
        floatingLabelStyle: Styles.textNormal.apply(
          color: hasError ? Styles.colorDanger : Styles.colorPrimary,
        ),
        errorStyle: Styles.textSub.apply(
          color: Styles.colorDanger,
        ),
        hintStyle: Styles.textNormal.apply(
          color: Styles.colorHint,
        ),
        suffixIcon: displayClearButton || displayVisibilityButton
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (displayClearButton) clearButton,
                  if (displayVisibilityButton) visibilityButton,
                ],
              )
            : null,
      ),
    );
  }
}
