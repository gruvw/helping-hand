import "package:flutter/material.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/component/structure/title_bar.dart";

class RemotesScreen extends StatelessWidget {
  const RemotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            return ListTile(
              leading: Icon(Styles.iconAdd),
              title: Text("Register New Remote"),
              onTap: () {
                // TODO new remote registration
              },
            );
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
