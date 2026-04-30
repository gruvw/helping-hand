import "package:flutter_test/flutter_test.dart";
import "package:helping_hand/utils/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:hooks_riverpod/legacy.dart";

void main() {
  test(
    "filterAsync keeps the previous value when the new value is rejected",
    () {
      final container = ProviderContainer();
      final source = StateProvider<AsyncValue<int>>(
        (ref) => const AsyncData(10),
      );
      final filtered = source.filterAsync((n) => n % 2 == 0);

      final sub = container.listen(filtered, (_, _) {});

      expect(sub.read(), const AsyncData(10));

      container.read(source.notifier).state = const AsyncData(11);
      expect(sub.read(), const AsyncData(10));

      container.read(source.notifier).state = const AsyncData(12);
      expect(sub.read(), const AsyncData(12));

      sub.close();
    },
  );

  test("whereNotNull narrows type and retains state on null emission", () {
    final container = ProviderContainer();
    final source = StateProvider<AsyncValue<String?>>(
      (ref) => const AsyncData("Object A"),
    );
    final narrowed = source.whereNotNull();

    final sub = container.listen(narrowed, (_, _) {});

    final firstState = sub.read();
    expect(firstState.value, "Object A");
    final String _ = firstState.requireValue;

    container.read(source.notifier).state = const AsyncData(null);

    final secondState = sub.read();
    expect(secondState.value, "Object A");
    expect(secondState.hasValue, true);

    sub.close();
  });

  test("whereNotNull starts in loading if the initial value is null", () {
    final container = ProviderContainer();
    final source = StateProvider<AsyncValue<String?>>(
      (ref) => const AsyncData(null),
    );
    final narrowed = source.whereNotNull();

    final sub = container.listen(narrowed, (_, _) {});

    expect(sub.read(), isA<AsyncLoading<String>>());

    container.read(source.notifier).state = const AsyncData("Object B");
    expect(sub.read().value, "Object B");

    sub.close();
  });

  test("forwards errors regardless of filter", () {
    final container = ProviderContainer();
    final source = StateProvider<AsyncValue<int>>((ref) => const AsyncData(10));
    final filtered = source.filterAsync((n) => n > 100);

    final sub = container.listen(filtered, (_, _) {});

    expect(sub.read(), isA<AsyncLoading<int>>());

    final exception = Exception("DB Error");
    container.read(source.notifier).state = AsyncError(
      exception,
      StackTrace.empty,
    );

    expect(sub.read().error, exception);

    sub.close();
  });
}
