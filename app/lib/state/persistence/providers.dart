import "package:helping_hand/state/persistence/database/core/database.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final dbProvider = Provider<Database>(
  (ref) => Database.native(),
);

final remoteNamesProvider = StreamProvider<List<String>>((ref) {
  final db = ref.watch(dbProvider);

  return db
      .select(db.remoteTable)
      .map((remote) => remote.name)
      .watch()
      .distinct();
});

// final highScoreForTrainingLengthProvider =
//     StreamProvider.family<Score?, GameSetting>(
//       (ref, gameSetting) {
//         final db = ref.watch(dbProvider);

//         final query = db.select(db.highScoreTable)
//           ..where(
//             (t) =>
//                 t.gameId.equals(gameSetting.gameId) &
//                 t.length.equals(gameSetting.length),
//           );

//         return query.watchSingleOrNull();
//       },
//     );

// final highScoreSelectedTrainingLengthProvider =
//     FutureProvider.family<Score?, GameId>(
//       (ref, gameId) {
//         final selectedTrainingLength = ref
//             .watch(kvsTrainingLengthProvider)
//             .requireValue;

//         return ref
//             .watch(
//               highScoreForTrainingLengthProvider((
//                 gameId: gameId,
//                 length: selectedTrainingLength,
//               )),
//             )
//             .requireValue;
//       },
//     );
