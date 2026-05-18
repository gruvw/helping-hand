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
import "package:helping_hand/view/navigation/routes.dart";
import "package:helping_hand/view/page/tiles/move_folder_dialog.dart";
import "package:helping_hand/view/page/tiles/tiles_grid.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class TilesPage extends ConsumerWidget {
  const TilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final currentTileId = ref.watch(currentTileIdProvider);
    final currentTileIdValue = currentTileId.id;

    final appBar = AppBar(
      title: Text(Values.applicationTitle),
      backgroundColor: Styles.colorPrimary,
      foregroundColor: Styles.colorSecondary,
      leading: currentTileId.isRootFolder
          ? IconButton(
              onPressed: () {
                context.push(AppRoutes.settings.path);
              },
              icon: Icon(Styles.iconSettings),
              tooltip: "Settings",
            )
          : IconButton(
              onPressed: () {
                // FIXME (later) handle device based back navigation for tiles (like android back touch)
                ref.read(currentTileIdPathProvider.notifier).pop();
              },
              icon: Icon(
                Styles.iconPrevious,
                color: Styles.colorSecondary,
              ),
              tooltip: "Back",
            ),
      actions: [
        PopupMenuButton(
          tooltip: "Menu",
          icon: Icon(
            Styles.iconMore,
            color: Styles.colorSecondary,
          ),
          color: Styles.colorSecondary,
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () {
                context.push(AppRoutes.remotes.path);
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
                        title: "New Folder",
                        inputLabel: "Folder name",
                        validation: (folderName) {
                          if (folderName.isEmpty) {
                            return InvalidResult(
                              errorMessage: "Folder name can't be empty.",
                            );
                          }

                          if (folderName.contains(TileId.folderPathSeparator)) {
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
                  title: Text("New folder"),
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
                        inputLabel: "Folder name",
                        placeholder: ref
                            .read(
                              folderProvider(currentTileIdValue),
                            )
                            .value
                            ?.name,
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
                  title: Text("Rename folder"),
                ),
              ),
            if (currentTileId is FolderTileId && currentTileIdValue != null)
              PopupMenuItem(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return MoveFolderDialog(
                        currentFolderId: currentTileIdValue,
                        parentFolderId: currentTileId.parentId,
                      );
                    },
                  );
                },
                child: ListTile(
                  leading: Icon(
                    Styles.iconMove,
                    color: Styles.colorPrimary,
                  ),
                  title: Text("Move folder to"),
                ),
              ),
            if (currentTileIdValue != null)
              PopupMenuItem(
                onTap: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return DeletionDialog(
                        title: "Delete Tile",
                        content: "Do you really want to delete this tile?",
                        onDelete: () async {
                          await db.queries.removeTile(
                            parentId: currentTileId.parentId,
                            tileId: currentTileIdValue,
                          );
                          ref.read(currentTileIdPathProvider.notifier).pop();
                          return true;
                        },
                      );
                    },
                  );
                },
                child: ListTile(
                  iconColor: Styles.colorDanger,
                  textColor: Styles.colorDanger,
                  leading: Icon(Styles.iconDelete),
                  title: Text("Delete tile"),
                ),
              ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: TilesGrid(),
    );
  }
}
