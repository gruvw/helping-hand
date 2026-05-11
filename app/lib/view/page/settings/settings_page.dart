import "package:flutter/material.dart";
import "package:helping_hand/state/persistence/kvs/providers.dart";
import "package:helping_hand/static/styles.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibleUiAsync = ref.watch(kvsAccessibleUiProvider);
    final useHttpsAsync = ref.watch(kvsHttpsProvider);

    final content = ListView(
      children: [
        accessibleUiAsync.maybeWhen(
          data: (value) {
            return SwitchListTile(
              activeThumbColor: Styles.colorSuccess,
              title: Text("Use Accessible UI"),
              value: value,
              onChanged: (newValue) {
                ref.read(kvsAccessibleUiProvider.notifier).set(newValue);
              },
            );
          },
          orElse: () {
            return ListTile(
              title: Text("Use Accessible UI"),
            );
          },
        ),
        useHttpsAsync.maybeWhen(
          data: (value) {
            return SwitchListTile(
              activeThumbColor: Styles.colorSuccess,
              title: Text("Use HTTPs"),
              value: value,
              onChanged: (newValue) {
                ref.read(kvsHttpsProvider.notifier).set(newValue);
              },
            );
          },
          orElse: () {
            return ListTile(
              title: Text("Use HTTPs"),
            );
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.colorPrimary,
        foregroundColor: Styles.colorSecondary,
        title: Text("Settings"),
      ),
      body: content,
    );
  }
}
