import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:helping_hand/view/application.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

void main() {
  // final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // TODO splash screen with app logo
  // preserve the splash screen for initialization
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // set browser URL when pushing routes
  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(
    ProviderScope(
      child: const Application(),
    ),
  );
}
