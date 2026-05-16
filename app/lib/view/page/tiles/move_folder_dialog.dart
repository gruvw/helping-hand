import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";
import "package:helping_hand/view/component/dialog/cancel_dialog.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class MoveFolderDialog extends HookConsumerWidget {
  final String currentFolderId;
  final String? parentFolderId;

  const MoveFolderDialog({
    super.key,
    required this.currentFolderId,
    required this.parentFolderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersSnapshot = useFuture(
      useMemoized(
        () => ref
            .read(dbProvider)
            .queries
            .getPaths(currentFolderId, parentFolderId),
      ),
    );

    final targets = foldersSnapshot.data
        ?.map(
          (folder) => InkWell(
            onTap: () async {
              await ref
                  .read(dbProvider)
                  .queries
                  .moveFolderTo(
                    folderId: currentFolderId,
                    newParentFolderId: folder.$1,
                  );

              ref.read(currentTileIdPathProvider.notifier).clear();

              if (context.mounted) {
                context.pop();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 4,
              ),
              child: Row(
                children: [
                  Text(
                    folder.$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();

    final content = switch (targets) {
      null => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Styles.colorPrimary,
          ),
        ],
      ),
      _ => SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: targets.isEmpty
              ? [Text("No target folder.")]
              : targets.separateWith(
                  Divider(
                    height: 3,
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    };

    return CancelDialog(
      title: "Move Folder To",
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * 0.7,
            ),
            child: content,
          );
        },
      ),
    );
  }
}
