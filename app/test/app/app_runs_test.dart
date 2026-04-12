import "package:flutter_test/flutter_test.dart";
import "package:helping_hand/view/application.dart";
import "package:helping_hand/view/navigation/router.dart";
import "package:helping_hand/view/navigation/routes.dart";

import "../helpers/app_generator.dart";

void main() {
  testWidgets("application runs", (tester) async {
    await pumpTestApp(tester);

    expect(find.byType(Application), findsOneWidget);

    expect(
      router.state.path,
      AppRoutes.initial.path,
      reason: "application should be on initial route",
    );
  });
}
