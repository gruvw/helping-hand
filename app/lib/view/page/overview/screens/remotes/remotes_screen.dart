import "package:flutter/material.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/state/request.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/dialog/async_text_dialog.dart";
import "package:helping_hand/view/component/structure/title_bar.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class RemotesScreen extends ConsumerWidget {
  const RemotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newRemoteButton = ListTile(
      leading: Icon(Styles.iconAdd),
      title: Text("Register New Remote"),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AsyncTextDialog(
            title: "Register New Remote",
            inputLabel: "Remote name",
            placeholder: "hh-0001",
            submitText: "Register",
            validation: (name) async {
              return ref
                  .read(requestProvider)
                  .getConfig(remoteName: name)
                  .then(
                    (_) => ValidResult(),
                    onError: (e) => InvalidResult(
                      errorMessage: "could not reach the remote: $e",
                    ),
                  );
            },
            onSubmit: (name) async {
              // TODO save remote
              return true;
            },
          ),
        );
      },
    );

    final length = 10;
    return TitleScreen(
      title: "Remotes",
      child: ListView.separated(
        itemCount: length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (context, index) {
          if (index == length - 1) {
            return newRemoteButton;
          }

          return ExpansionTile(
            title: Text(
              index.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: const Border(),
            children: Iterable.generate(10, (i) => i).map((item) {
              return ListTile(
                title: Text(item.toString()),
                leading: Icon(Icons.label_outline, size: 18),
                onTap: () {},
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
