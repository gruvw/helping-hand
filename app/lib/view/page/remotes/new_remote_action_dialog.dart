import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:helping_hand/logic/action_state.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/model/config/action.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/state/remote_request_provider.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/static/values.dart";
import "package:helping_hand/view/component/button/outlined.dart";
import "package:helping_hand/view/component/button/solid.dart";
import "package:helping_hand/view/component/dialog/cancel_dialog.dart";
import "package:helping_hand/view/component/structure/text_input.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class NewRemoteActionDialog extends HookConsumerWidget {
  final String remoteId;

  const NewRemoteActionDialog({
    super.key,
    required this.remoteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteRequestService = ref.watch(
      remoteRequestServiceProvider(remoteId),
    );

    final nameController = useTextEditingController();
    final nameError = useState<ValidationResult?>(null);

    final port = useState(1);
    final positionAngle = useState(Values.minPositionAngle);
    final pressAngleDelta = useState(Values.minPressAngleDelta);
    final maxPressAngleDelta =
        Values.maxPressAngle - positionAngle.value - Values.minPressAngleDelta;
    // FIXME (later) constant for now, could be user customizable later
    const clickDurationMs = 50;

    final setSuccess = useState(false);
    final clickSuccess = useState(false);
    final actionState = useState(ActionState.nothing);

    Future<void> reset() {
      if (context.mounted) {
        positionAngle.value = Values.minPositionAngle;
        pressAngleDelta.value = Values.minPressAngleDelta;

        actionState.value = ActionState.nothing;
        setSuccess.value = false;
        clickSuccess.value = false;
      }

      return remoteRequestService
          .reset(channel: Values.allChannels)
          .then(
            (_) {
              if (context.mounted) {
                actionState.value = ActionState.nothing;
              }
            },
            onError: (_) {
              if (context.mounted) {
                actionState.value = ActionState.error;
              }
            },
          );
    }

    Future<bool> set() {
      if (context.mounted) {
        actionState.value = ActionState.pending;
      }

      return remoteRequestService
          .set(
            channel: port.value,
            angle: positionAngle.value,
          )
          .then<bool>(
            (_) {
              if (context.mounted) {
                actionState.value = ActionState.success;
                setSuccess.value = true;
              }
              return true;
            },
            onError: (_) {
              if (context.mounted) {
                actionState.value = ActionState.error;
              }
              return false;
            },
          );
    }

    Future<bool> click() {
      if (context.mounted) {
        actionState.value = ActionState.pending;
      }

      return remoteRequestService
          .perform(
            ClickConfig(
              name: nameController.text,
              channel: port.value,
              angle: positionAngle.value + pressAngleDelta.value,
              durationMs: clickDurationMs,
            ),
          )
          .then<bool>(
            (_) {
              if (context.mounted) {
                actionState.value = ActionState.success;
                clickSuccess.value = true;
              }
              return true;
            },
            onError: (_) {
              if (context.mounted) {
                actionState.value = ActionState.error;
              }
              return false;
            },
          );
    }

    Future<void> applyPositionAngleDelta(int delta) async {
      final previousPositionAngle = positionAngle.value;

      positionAngle.value = (positionAngle.value + delta).clamp(
        Values.minPositionAngle,
        Values.maxPositionAngle,
      );
      pressAngleDelta.value = Values.minPressAngleDelta;

      final success = await set();
      if (!success) {
        if (context.mounted) {
          positionAngle.value = previousPositionAngle;
        }
      }
    }

    Future<void> applyClickAngleDelta(int delta) async {
      final previousPressAngleDelta = pressAngleDelta.value;

      pressAngleDelta.value = (pressAngleDelta.value + delta).clamp(
        Values.minPressAngleDelta,
        maxPressAngleDelta,
      );

      final success = await click();
      if (!success) {
        if (context.mounted) {
          pressAngleDelta.value = previousPressAngleDelta;
        }
      }
    }

    useEffect(() {
      reset();
      return () => reset();
    }, const []);

    final sendEnabled = actionState.value != ActionState.pending;

    const distAngleDelta = 2;
    const doubleDistAngleDelta = 5;
    const trippleDistAngleDelta = 10;

    const textStyle = TextStyle(fontSize: 16);
    const itemsSpacing = Gap(10);
    const actionSpacing = Gap(8);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              "Port:",
              style: textStyle,
            ),
            Spacer(),
            OutlinedButtonPrimary(
              enabled: sendEnabled && port.value != 0,
              onPressed: () {
                port.value = max(1, port.value - 1);
                reset();
              },
              child: Icon(Styles.iconLeft),
            ),
            Gap(6),
            Text(port.value.toString()),
            Gap(6),
            OutlinedButtonPrimary(
              enabled: sendEnabled && port.value != Values.maxChannel,
              onPressed: () {
                port.value = min(Values.maxChannel, port.value + 1);
                reset();
              },
              child: Icon(Styles.iconRight),
            ),
            Spacer(),
            SizedBox(
              width: 24,
              height: 24,
              child: switch (actionState.value) {
                ActionState.nothing => SizedBox(),
                ActionState.pending => SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Styles.colorPrimary,
                  ),
                ),
                ActionState.success => Icon(
                  Styles.iconSuccess,
                  color: Styles.colorSuccess,
                ),
                ActionState.error => Icon(
                  Styles.iconError,
                  color: Styles.colorDanger,
                ),
              },
            ),
          ],
        ),
        itemsSpacing,
        TextInput(
          controller: nameController,
          label: "Action Name",
          placeholder: "Turn on",
          errorText: nameError.value?.errorMessage,
          onChanged: (value) {
            final matches = nameRegex.hasMatch(value);

            if (!matches) {
              nameError.value = InvalidResult(errorMessage: "Invalid name.");
              return;
            }

            nameError.value = ValidResult();
          },
        ),
        itemsSpacing,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Positionning",
              style: textStyle,
            ),
            SolidButtonPrimary(
              enabled: sendEnabled,
              onPressed: set,
              child: Text("Set"),
            ),
          ],
        ),
        actionSpacing,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            SolidButtonPrimary(
              enabled:
                  sendEnabled &&
                  setSuccess.value &&
                  positionAngle.value < Values.maxPositionAngle,
              onPressed: () => applyPositionAngleDelta(doubleDistAngleDelta),
              onLongPress: () => applyPositionAngleDelta(trippleDistAngleDelta),
              child: Icon(Styles.iconDoubleDown),
            ),
            SolidButtonPrimary(
              enabled:
                  sendEnabled &&
                  setSuccess.value &&
                  positionAngle.value < Values.maxPositionAngle,
              onPressed: () => applyPositionAngleDelta(distAngleDelta),
              child: Icon(Styles.iconDown),
            ),
            SolidButtonPrimary(
              enabled:
                  sendEnabled &&
                  setSuccess.value &&
                  positionAngle.value > Values.minPositionAngle,
              onPressed: () => applyPositionAngleDelta(-distAngleDelta),
              child: Icon(Styles.iconUp),
            ),
            SolidButtonPrimary(
              enabled:
                  sendEnabled &&
                  setSuccess.value &&
                  positionAngle.value > Values.minPositionAngle,
              onPressed: () => applyPositionAngleDelta(-doubleDistAngleDelta),
              onLongPress: () =>
                  applyPositionAngleDelta(-trippleDistAngleDelta),
              child: Icon(Styles.iconDoubleUp),
            ),
          ],
        ),
        itemsSpacing,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Click test",
              style: textStyle,
            ),
            SolidButtonPrimary(
              enabled: sendEnabled && setSuccess.value,
              onPressed: click,
              child: Text("Click"),
            ),
          ],
        ),
        actionSpacing,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            SolidButtonPrimary(
              enabled:
                  sendEnabled &&
                  setSuccess.value &&
                  clickSuccess.value &&
                  pressAngleDelta.value < maxPressAngleDelta,
              onPressed: () => applyClickAngleDelta(doubleDistAngleDelta),
              onLongPress: () => applyClickAngleDelta(trippleDistAngleDelta),
              child: Icon(Styles.iconDoubleDown),
            ),
            SolidButtonPrimary(
              enabled:
                  sendEnabled &&
                  setSuccess.value &&
                  clickSuccess.value &&
                  pressAngleDelta.value < maxPressAngleDelta,
              onPressed: () => applyClickAngleDelta(distAngleDelta),
              child: Icon(Styles.iconDown),
            ),
            SolidButtonPrimary(
              enabled:
                  sendEnabled &&
                  setSuccess.value &&
                  clickSuccess.value &&
                  pressAngleDelta.value > Values.minPressAngleDelta,
              onPressed: () => applyClickAngleDelta(-distAngleDelta),
              child: Icon(Styles.iconUp),
            ),
            SolidButtonPrimary(
              enabled:
                  sendEnabled &&
                  setSuccess.value &&
                  clickSuccess.value &&
                  pressAngleDelta.value > Values.minPressAngleDelta,
              onPressed: () => applyClickAngleDelta(-distAngleDelta),
              onLongPress: () => applyClickAngleDelta(-trippleDistAngleDelta),
              child: Icon(Styles.iconDoubleUp),
            ),
          ],
        ),
      ],
    );

    return CancelDialog(
      title: "Register New Action",
      confirmEnabled:
          sendEnabled &&
          setSuccess.value &&
          clickSuccess.value &&
          nameController.text.isNotEmpty &&
          (nameError.value?.isValid ?? false),
      onConfirm: () async {
        actionState.value = ActionState.pending;

        final remote = ref.read(remoteNotifierProvider(remoteId)).value;
        final actions = remote?.actionConfigs;
        if (actions == null) {
          actionState.value = ActionState.error;
          nameError.value = InvalidResult(errorMessage: "Cannot reach remote.");
          return false;
        }

        if (actions.map((a) => a.name).contains(nameController.text)) {
          actionState.value = ActionState.error;
          nameError.value = InvalidResult(
            errorMessage: "An action with that name already exists.",
          );
          return false;
        }

        final success = await ref
            .read(remoteNotifierProvider(remoteId).notifier)
            .addAction(
              ClickConfig(
                name: nameController.text,
                channel: port.value,
                angle: positionAngle.value + pressAngleDelta.value,
                durationMs: clickDurationMs,
              ),
            )
            .then<bool>((success) {
              if (context.mounted) {
                actionState.value = success
                    ? ActionState.success
                    : ActionState.error;
              }
              return success;
            });

        return success;
      },
      body: Container(
        constraints: BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: body,
      ),
    );
  }
}
