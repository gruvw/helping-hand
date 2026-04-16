import "package:flutter/material.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/model/config/action.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/state/remote_request.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";
import "package:helping_hand/view/component/dialog/async_text_dialog.dart";
import "package:helping_hand/view/component/dialog/deletion_dialog.dart";
import "package:helping_hand/view/page/overview/screens/remotes/new_remote_action_dialog.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class RemoteLine extends ConsumerWidget {
  final String remoteId;

  const RemoteLine({
    super.key,
    required this.remoteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(remoteNotifierProvider(remoteId));

    final remoteName = remote.value?.name;
    final remoteFullName =
        remoteName?.nmap((name) => "$name ($remoteId)") ?? remoteId;

    final isOnline = remote.maybeWhen(
      data: (remote) => remote.isOnline ? true : false,
      orElse: () => false,
    );

    final item = ExpansionTile(
      title: Text(
        remoteFullName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      leading: remote.maybeWhen(
        data: (remote) => remote.isOnline ? null : Icon(Styles.iconOffline),
        orElse: () => SizedBox(
          width: 23,
          height: 23,
          child: CircularProgressIndicator(
            color: Styles.colorPrimary,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              // TODO add remote tile
            },
            icon: Icon(
              Styles.iconAdd,
              color: Styles.colorPrimary,
            ),
          ),
          PopupMenuButton(
            tooltip: "Options",
            color: Styles.colorSecondary,
            icon: Icon(
              Styles.iconEdit,
              color: Styles.colorPrimary,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AsyncTextDialog(
                        title: "Rename Remote",
                        inputLabel: "Remote name",
                        placeholder: remoteName,
                        submitText: "Rename",
                        validation: (remoteName) {
                          final match = nameRegex.firstMatch(remoteName);

                          if (match == null) {
                            return InvalidResult(
                              errorMessage: "Invalid remote name.",
                            );
                          }

                          return ValidResult();
                        },
                        onSubmit: (remoteName) async {
                          final success = await ref
                              .read(remoteNotifierProvider(remoteId).notifier)
                              .rename(remoteName);

                          if (!success) {
                            return InvalidResult(
                              errorMessage: "Could not rename the remote.",
                            );
                          }

                          return ValidResult();
                        },
                      );
                    },
                  );
                },
                enabled: isOnline,
                child: Text("Rename"),
              ),
              PopupMenuItem(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return DeletionDialog(
                        title: "Remove Remote",
                        content:
                            "Do you really want to remove the following remote?\nAll associated local configuration will be lost.",
                        target: remoteFullName,
                        onDelete: () async {
                          await ref
                              .read(dbProvider)
                              .queries
                              .removeRemote(remoteId);

                          return true;
                        },
                      );
                    },
                  );
                },
                child: Text(
                  "Remove",
                  style: TextStyle(color: Styles.colorDanger),
                ),
              ),
            ],
          ),
        ],
      ),
      enabled: isOnline,
      shape: const Border(),
      children: remote.maybeWhen(
        data: (remote) {
          final newActionItem = ListTile(
            leading: Icon(Styles.iconAdd),
            title: Text("Register New Action"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => NewRemoteActionDialog(
                  remoteId: remoteId,
                ),
              );
            },
          );

          return [
            ...?remote.actionConfigs?.map(
              (actionConfig) => ListTile(
                title: Text(actionConfig.name),
                leading: Icon(Styles.iconLabel),
                trailing: IconButton(
                  onPressed: () {
                    // TODO add button tile
                    ref
                        .read(remoteRequestServiceProvider(remoteId))
                        .perform(actionConfig);
                  },
                  icon: Icon(Styles.iconAdd),
                ),
              ),
            ),
            if (remote.isOnline) newActionItem,
          ];
        },
        orElse: () => [],
      ),
    );

    return isOnline || remote.isLoading
        ? item
        : GestureDetector(
            onTap: () {
              ref.invalidate(
                remoteConfigProvider(remoteId),
                asReload: true,
              );
            },
            child: item,
          );
  }
}
