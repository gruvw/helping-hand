import "package:flutter/material.dart";
import "package:helping_hand/logic/validation.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/dialog/async_text_dialog.dart";
import "package:helping_hand/view/component/structure/title_bar.dart";
import "package:http/http.dart" as http;

class RemotesScreen extends StatelessWidget {
  const RemotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // TODO dependency injection http service
              final uri = Uri.parse("http://$name.local");

              return http
                  .get(uri)
                  .timeout(
                    const Duration(seconds: 20),
                    onTimeout: () => throw Exception("Connection timed out"),
                  )
                  .then(
                    (_) => ValidResult(),
                    onError: (e) => InvalidResult(
                      errorMessage: "Could not detect remote. $e",
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
