import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:helping_hand/state/persistence/database/core/database.drift.dart";
import "package:helping_hand/state/persistence/database/queries/queries.dart";
import "package:helping_hand/state/persistence/database/tables/kvs_table.dart";
import "package:helping_hand/state/persistence/database/tables/remote_table.dart";
import "package:helping_hand/state/persistence/database/tables/tile_table.dart";
import "package:helping_hand/static/build_options.dart";
import "package:helping_hand/static/values.dart";

@DriftDatabase(
  tables: [
    TileTable,
    KvsTable,
    RemoteTable,
  ],
)
class Database extends $Database {
  static QueryExecutor _nativeConnection() {
    return driftDatabase(
      name: Values.databaseName,
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse("sqlite3.wasm"),
        driftWorker: Uri.parse("drift_worker.js"),
      ),
    );
  }

  late final queries = Queries(this);

  Database(super.executor);

  Database.native() : this(_nativeConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        final migrator = createMigrator();

        if (BuildOptions.debugEraseDB) {
          // delete and create fresh DB
          for (final table in allTables) {
            await migrator.deleteTable(table.actualTableName);
            await migrator.createTable(table);
          }
        }

        // enable SQLite foreign keys
        await customStatement("PRAGMA foreign_keys = ON");
      },
    );
  }
}
