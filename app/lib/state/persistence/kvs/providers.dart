import "package:helping_hand/state/persistence/kvs/kvs_notifier.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final kvsSourceProvider = StreamProvider.family<String?, String>(
  (ref, key) {
    final db = ref.watch(dbProvider);

    final query = (db.select(
      db.kvsTable,
    )..where((t) => t.key.equals(key))).map((row) => row.value);

    return query.watchSingleOrNull().distinct();
  },
);

final kvsAccessibleUiProvider = KvsNotifierProvider<bool>(
  () {
    return KvsNotifier.boolean(
      configKey: "accessible_ui",
      defaultValue: false,
    );
  },
);

// final kvsLastGameIdProvider =
//     NotifierProvider<KvsNotifier<String?>, AsyncValue<GameId?>>(() {
//       return KvsNotifier.string(
//         configKey: "last_game_id",
//         defaultValue: "",
//       ).map(
//         (value) => value.isEmpty ? null : value,
//         (data) => data ?? "",
//       );
//     });
