import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/database/tables/folder_table.drift.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/static/values.dart";
import "package:helping_hand/view/component/dialog/async_text_dialog.dart";
import "package:helping_hand/view/component/dialog/deletion_dialog.dart";
import "package:helping_hand/view/navigation/router.dart";
import "package:helping_hand/view/navigation/routes.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class OverviewPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const OverviewPage({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subNavigatorKey = overviewNavigatorKeys[navigationShell.currentIndex];

    final routerPath = router.routerDelegate.state.path;
    final isOnTiles = routerPath == OverviewRoute.tiles.path;

    final db = ref.watch(dbProvider);
    final currentTileId = ref.watch(currentTileIdProvider);
    final currentTileIdValue = currentTileId.id;

    final appBar = AppBar(
      title: Text(Values.applicationTitle),
      backgroundColor: Styles.colorPrimary,
      foregroundColor: Styles.colorSecondary,
      leading: isOnTiles && currentTileId.isRootFolder
          ? null
          : IconButton(
              onPressed: () {
                final subState = subNavigatorKey.currentState;
                if (subState == null || !subState.canPop()) {
                  context.go(AppRoutes.initial.path);
                } else {
                  subState.pop();
                }
              },
              icon: Icon(
                Styles.iconPrevious,
                color: Styles.colorSecondary,
              ),
            ),
      actions: [
        if (routerPath != OverviewRoute.remotes.path)
          PopupMenuButton(
            tooltip: "Edit",
            icon: Icon(
              Styles.iconMore,
              color: Styles.colorSecondary,
            ),
            color: Styles.colorSecondary,
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  context.push(OverviewRoute.remotes.path);
                },
                child: ListTile(
                  leading: Icon(
                    Styles.iconAddTile,
                    color: Styles.colorPrimary,
                  ),
                  title: Text("Remotes"),
                ),
              ),
              if (currentTileId is FolderTileId)
                PopupMenuItem(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AsyncTextDialog(
                          title: "New Folder Name",
                          validation: (folderName) {
                            if (folderName.isEmpty) {
                              return InvalidResult(
                                errorMessage: "Folder name can't be empty.",
                              );
                            }

                            if (folderName.contains(TileId.folderPrefix) ||
                                folderName.contains(
                                  TileId.folderPathSeparator,
                                )) {
                              return InvalidResult(
                                errorMessage: "Invalid folder name.",
                              );
                            }

                            return ValidResult();
                          },
                          onSubmit: alwaysValid((folderName) async {
                            return ref
                                .read(dbProvider)
                                .queries
                                .createFolder(
                                  name: folderName,
                                  parentFolderId: currentTileId.folderId,
                                );
                          }),
                        );
                      },
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      Styles.iconAddFolder,
                      color: Styles.colorPrimary,
                    ),
                    title: Text("New Folder"),
                  ),
                ),
              if (currentTileId is FolderTileId && currentTileIdValue != null)
                PopupMenuItem(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AsyncTextDialog(
                          title: "Rename Folder",
                          onSubmit: alwaysValid((newFolderName) async {
                            await db
                                .into(db.folderTable)
                                .insertOnConflictUpdate(
                                  FolderTableCompanion.insert(
                                    id: currentTileIdValue,
                                    name: newFolderName,
                                  ),
                                );
                          }),
                        );
                      },
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      Styles.iconEdit,
                      color: Styles.colorPrimary,
                    ),
                    title: Text("Rename Folder"),
                  ),
                ),
              if (currentTileIdValue != null)
                PopupMenuItem(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DeletionDialog(
                          title: "Delete Tile",
                          content: "Do you really want to delete this tile?",
                          onDelete: () async {
                            await db.queries.deleteTile(
                              parentId: currentTileId.parentId,
                              tileId: currentTileIdValue,
                            );
                            return true;
                          },
                        );
                      },
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      Styles.iconEdit,
                      color: Styles.colorPrimary,
                    ),
                    title: Text("Delete tile"),
                  ),
                ),
              // TODO move folder tile context menu
            ],
          ),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        print("hey");
        if (didPop) {
          return;
        }

        final tilePopped = ref.read(currentTileIdPathProvider.notifier).pop();

        if (!tilePopped && context.mounted) {
          subNavigatorKey.currentState?.pop();
        }
      },
      child: Scaffold(
        appBar: appBar,
        body: navigationShell,
      ),
    );
  }
}
