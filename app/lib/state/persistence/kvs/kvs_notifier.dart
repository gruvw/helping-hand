import "package:helping_hand/state/persistence/database/tables/kvs_table.drift.dart";
import "package:helping_hand/state/persistence/kvs/providers.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/utils/language.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

typedef KvsNotifierProvider<T> =
    NotifierProvider<KvsNotifier<T>, AsyncValue<T>>;

class KvsNotifier<T> extends Notifier<AsyncValue<T>> {
  static KvsNotifier<bool> boolean({
    required String configKey,
    required bool defaultValue,
  }) {
    return KvsNotifier(
      key: configKey,
      defaultValue: defaultValue,
      parse: (s) => bool.parse(s),
      serialize: (v) => v.toString(),
    );
  }

  static KvsNotifier<int> integer({
    required String configKey,
    required int defaultValue,
  }) {
    return KvsNotifier(
      key: configKey,
      defaultValue: defaultValue,
      parse: (s) => int.parse(s),
      serialize: (v) => v.toString(),
    );
  }

  static KvsNotifier<String> string({
    required String configKey,
    required String defaultValue,
  }) {
    return KvsNotifier(
      key: configKey,
      defaultValue: defaultValue,
      serialize: (s) => s,
      parse: (s) => s,
    );
  }

  final String key;
  final T defaultValue;

  /// The serialization function used to convert the value to text for storage.
  /// Note - This function should be pure and idempotent.
  final String Function(T value) serialize;

  /// The parsing function used to convert the stored text to the (typed) value.
  /// Note - This function should be pure and idempotent.
  final T Function(String source) parse;

  KvsNotifier({
    required this.key,
    required this.defaultValue,
    required this.serialize,
    required this.parse,
  });

  @override
  AsyncValue<T> build() {
    final sourceAsync = ref.watch(kvsSourceProvider(key));

    return sourceAsync.whenData(
      (source) {
        final value = source?.nmap((source) => parse(source));
        return value ?? defaultValue;
      },
    );
  }

  /// Assigns a new value to the key in the store, with (opt-out) immediate effect on the notifier's state.
  /// Note - if the state is immediately updated, it could de-synchronize the store and the notifier's state.
  Future<void> set(
    T value, {
    bool immediate = true,
  }) async {
    if (immediate) {
      state = AsyncValue.data(value);
    }

    final data = serialize(value);
    final db = ref.read(dbProvider);
    await db
        .into(db.kvsTable)
        .insertOnConflictUpdate(
          KvsTableCompanion.insert(
            key: key,
            value: data,
          ),
        );
  }

  /// Resets the value to its default.
  /// Effectively removes the key from the store.
  /// The effect is not immediately reflected on the notifier.
  Future<void> reset() async {
    final db = ref.read(dbProvider);
    final delete = (db.delete(db.kvsTable))..where((t) => t.key.equals(key));

    await delete.go();
  }

  KvsNotifier<E> map<E>(
    E Function(T) transform,
    T Function(E) inverse,
  ) {
    return KvsNotifier<E>(
      key: key,
      defaultValue: transform(defaultValue),
      serialize: (value) => serialize(inverse(value)),
      parse: (source) => transform(parse(source)),
    );
  }
}
