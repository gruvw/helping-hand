import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

void main() {
  runApp(ProviderScope(child: const Application()));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Hello World!"),
        ),
      ),
    );
  }
}
