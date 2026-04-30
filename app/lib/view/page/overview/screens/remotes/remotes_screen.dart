import "package:drift/drift.dart";
import "package:flutter/material.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/state/persistence/database/tables/remote_table.drift.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_request.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/dialog/async_text_dialog.dart";
import "package:helping_hand/view/component/structure/title_bar.dart";
import "package:helping_hand/view/page/overview/screens/remotes/remote_line.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class RemotesScreen extends ConsumerWidget {
  const RemotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    final remoteIds = ref.watch(remoteIdsProvider);

    final newRemoteItem = ListTile(
      leading: Icon(
        Styles.iconAdd,
        color: Styles.colorPrimary,
      ),
      title: Text("Register New Remote"),
      onTap: () {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AsyncTextDialog(
            title: "Register New Remote",
            inputLabel: "Remote name",
            placeholder: "hh-0001",
            submitText: "Register",
            onSubmit: (remoteId) async {
              final result = await ref
                  .read(remoteRequestServiceProvider(remoteId))
                  .getConfig()
                  .then<ValidationResult>(
                    (_) => ValidResult(),
                    onError: (e) => InvalidResult(
                      // FIXME (later) proper user facing errors
                      errorMessage: "could not reach the remote: $e",
                    ),
                  );

              if (!result.isValid) {
                return result;
              }

              await db
                  .into(db.remoteTable)
                  .insert(
                    RemoteTableCompanion.insert(
                      id: remoteId,
                      name: remoteId,
                    ),
                    mode: InsertMode.insertOrIgnore,
                  );

              return result;
            },
          ),
        );
      },
    );

    return TitleScreen(
      title: "Remotes",
      onRefresh: () async {
        return ref.invalidate(
          remoteConfigProvider,
          asReload: true,
        );
      },
      child: remoteIds.maybeWhen(
        data: (remoteIds) {
          return ListView.separated(
            itemCount: remoteIds.length + 1,
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemBuilder: (context, index) {
              if (index == remoteIds.length) {
                return newRemoteItem;
              }

              return RemoteLine(remoteId: remoteIds[index]);
            },
          );
        },
        orElse: () => Center(
          child: CircularProgressIndicator(
            color: Styles.colorPrimary,
          ),
        ),
      ),
    );
  }
}
