import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/model/config/action.dart";
import "package:helping_hand/model/config/remote.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/state/remote_request_provider.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";
import "package:helping_hand/utils/riverpod.dart";
import "package:helping_hand/view/component/dialog/async_text_dialog.dart";
import "package:helping_hand/view/component/dialog/deletion_dialog.dart";
import "package:helping_hand/view/page/remotes/new_remote_action_dialog.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class RemoteLine extends ConsumerWidget {
  final String remoteId;

  const RemoteLine({
    super.key,
    required this.remoteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTileId = ref.watch(currentTileIdProvider);
    final remote = ref.watch(remoteNotifierProvider(remoteId).whereNotNull());
    final onFolderTile = currentTileId is FolderTileId;

    final remoteName = remote.maybeWhen(
      data: (r) => r.name,
      orElse: () => null,
      skipLoadingOnReload: true,
    );

    final remoteFullName =
        remoteName?.nmap(
          (name) => name != remoteId ? "$name ($remoteId)" : remoteId,
        ) ??
        remoteId;

    final isOnline = remote.maybeWhen(
      data: (r) => r.isOnline,
      orElse: () => false,
    );

    final item = ExpansionTile(
      collapsedTextColor: Styles.colorPrimary,
      collapsedIconColor: Styles.colorPrimary,
      iconColor: Styles.colorPrimary,
      textColor: Styles.colorPrimary,
      title: Text(
        remoteFullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      leading: remote.unwrapPrevious().maybeWhen(
        data: (r) => r.isOnline
            ? null
            : Icon(
                Styles.iconOffline,
                color: Styles.colorPrimary,
              ),
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
          if (onFolderTile)
            IconButton(
              onPressed: () async {
                await ref
                    .read(dbProvider)
                    .queries
                    .createTile(
                      id: remoteId,
                      parentFolderId: currentTileId.id,
                    );
                if (context.mounted) context.pop();
              },
              icon: Icon(
                Styles.iconAddTile,
                color: Styles.colorPrimary,
              ),
            ),
          _RemoteOptionsMenu(
            currentTileId: currentTileId,
            remoteId: remoteId,
            remoteName: remoteName,
            remoteFullName: remoteFullName,
            isOnline: isOnline,
          ),
        ],
      ),
      enabled: isOnline,
      shape: const Border(),
      children: remote.unwrapPrevious().maybeWhen(
        data: (remote) {
          final actionTiles =
              remote.actionConfigs?.map(
                (actionConfig) => _ActionTile(
                  remote: remote,
                  remoteId: remoteId,
                  actionConfig: actionConfig,
                  onFolderTile: onFolderTile,
                  currentTileId: currentTileId,
                  isOnline: isOnline,
                ),
              ) ??
              [];

          return [
            ...actionTiles,
            if (remote.isOnline)
              ListTile(
                leading: Icon(
                  Styles.iconAdd,
                  color: Styles.colorPrimary,
                ),
                title: const Text("Register New Action"),
                onTap: () => showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => NewRemoteActionDialog(
                    remoteId: remoteId,
                  ),
                ),
              ),
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

class _RemoteOptionsMenu extends ConsumerWidget {
  final TileId currentTileId;
  final String remoteId;
  final String? remoteName;
  final String remoteFullName;
  final bool isOnline;

  const _RemoteOptionsMenu({
    required this.currentTileId,
    required this.remoteId,
    required this.remoteName,
    required this.remoteFullName,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      tooltip: "Options",
      color: Styles.colorSecondary,
      icon: Icon(
        Styles.iconMore,
        color: Styles.colorPrimary,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: isOnline,
          onTap: () => _showRenameDialog(context, ref),
          child: ListTile(
            leading: Icon(
              Styles.iconEdit,
              color: Styles.colorPrimary,
            ),
            title: const Text("Rename"),
          ),
        ),
        PopupMenuItem(
          onTap: () => _showDeleteDialog(context, ref),
          child: ListTile(
            leading: Icon(
              Styles.iconDelete,
              color: Styles.colorDanger,
            ),
            title: Text(
              "Remove",
              style: TextStyle(color: Styles.colorDanger),
            ),
          ),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AsyncTextDialog(
          title: "Rename Remote",
          inputLabel: "Remote name",
          placeholder: remoteName,
          submitText: "Rename",
          validation: (newName) {
            final match = nameRegex.firstMatch(newName);
            if (match == null) {
              return InvalidResult(errorMessage: "Invalid remote name.");
            }
            return ValidResult();
          },
          onSubmit: (newName) async {
            final success = await ref
                .read(remoteNotifierProvider(remoteId).notifier)
                .rename(newName);

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
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DeletionDialog(
          title: "Remove Remote",
          content:
              "Do you really want to remove the following remote?\nAll associated local configuration will be lost.",
          target: remoteFullName,
          onDelete: () async {
            await ref.read(dbProvider).queries.removeRemote(remoteId);
            if (currentTileId.id == remoteId) {
              ref.read(currentTileIdPathProvider.notifier).pop();
            }

            return true;
          },
        );
      },
    );
  }
}

class _ActionTile extends ConsumerWidget {
  final Remote remote;
  final String remoteId;
  final ActionConfig actionConfig;
  final bool onFolderTile;
  final TileId currentTileId;
  final bool isOnline;

  const _ActionTile({
    required this.remote,
    required this.remoteId,
    required this.actionConfig,
    required this.onFolderTile,
    required this.currentTileId,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(actionConfig.name),
      leading: Icon(
        Styles.iconLabel,
        color: Styles.colorPrimary,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onFolderTile)
            IconButton(
              onPressed: () async {
                await ref
                    .read(dbProvider)
                    .queries
                    .createTile(
                      id: remoteId + TileId.actionSeparator + actionConfig.name,
                      parentFolderId: currentTileId.id,
                    );
                if (context.mounted) context.pop();
              },
              icon: Icon(
                Styles.iconAddTile,
                color: Styles.colorPrimary,
              ),
            ),
          _ActionOptionsMenu(
            remote: remote,
            remoteId: remoteId,
            actionConfig: actionConfig,
            isOnline: isOnline,
          ),
        ],
      ),
    );
  }
}

class _ActionOptionsMenu extends ConsumerWidget {
  final Remote remote;
  final String remoteId;
  final ActionConfig actionConfig;
  final bool isOnline;

  const _ActionOptionsMenu({
    required this.remote,
    required this.remoteId,
    required this.actionConfig,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      tooltip: "Options",
      color: Styles.colorSecondary,
      icon: Icon(
        Styles.iconMore,
        color: Styles.colorPrimary,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: isOnline,
          onTap: () => _showRenameDialog(context, ref),
          child: ListTile(
            leading: Icon(
              Styles.iconEdit,
              color: Styles.colorPrimary,
            ),
            title: const Text("Rename"),
          ),
        ),
        PopupMenuItem(
          onTap: () => _showDeleteDialog(context, ref),
          child: ListTile(
            leading: Icon(
              Styles.iconDelete,
              color: Styles.colorDanger,
            ),
            title: Text(
              "Remove",
              style: TextStyle(color: Styles.colorDanger),
            ),
          ),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AsyncTextDialog(
          title: "Rename Action",
          inputLabel: "Action name",
          placeholder: actionConfig.name,
          submitText: "Rename",
          validation: (actionName) {
            final match = nameRegex.firstMatch(actionName);
            if (match == null) {
              return InvalidResult(errorMessage: "Invalid action name.");
            }
            return ValidResult();
          },
          onSubmit: (actionNewName) async {
            final actions = remote.actionConfigs;
            if (actions == null) {
              return InvalidResult(errorMessage: "Cannot reach remote.");
            }

            if (actions.map((a) => a.name).contains(actionNewName)) {
              return InvalidResult(
                errorMessage: "An action with that name already exists.",
              );
            }

            final success = await ref
                .read(
                  remoteNotifierProvider(remoteId).notifier,
                )
                .renameAction(
                  actionConfig.name,
                  actionNewName,
                );

            if (!success) {
              return InvalidResult(
                errorMessage: "Could not rename the action.",
              );
            }
            return ValidResult();
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DeletionDialog(
          title: "Remove Action",
          content: "Do you really want to remove the following action?",
          target: actionConfig.name,
          onDelete: () async {
            await ref
                .read(remoteNotifierProvider(remoteId).notifier)
                .removeAction(actionConfig);
            return true;
          },
        );
      },
    );
  }
}
