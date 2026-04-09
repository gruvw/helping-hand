import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:helping_hand/main.dart";
import "package:helping_hand/state/persistence/database/core/database.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:hooks_riverpod/misc.dart";

Future<ProviderContainer> pumpTestApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  final inMemoryDb = Database(NativeDatabase.memory());
  addTearDown(inMemoryDb.close);

  final providerOverrides = [
    dbProvider.overrideWithValue(inMemoryDb),
    ...overrides,
  ];
  final container = ProviderContainer(
    overrides: providerOverrides,
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Application(),
    ),
  );
  await tester.pumpAndSettle();

  return container;
}
