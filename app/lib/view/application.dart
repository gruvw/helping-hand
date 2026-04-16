import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/static/values.dart";
import "package:helping_hand/view/navigation/router.dart";

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    // hide splash screen
    FlutterNativeSplash.remove();

    return MaterialApp.router(
      title: Values.applicationTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: Styles.fontFamily,
        scaffoldBackgroundColor: Styles.colorSecondary,
        primaryColor: Styles.colorPrimary,
        cardColor: Styles.colorSecondary,
        iconTheme: const IconThemeData(
          color: Styles.colorPrimary,
        ),
      ),
      routerConfig: router,
    );
  }
}
