import "dart:async";

import "package:helping_hand/model/config/remote.dart";
import "package:helping_hand/state/persistence/database/tables/remote_table.drift.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/request.dart";
import "package:helping_hand/utils/language.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class RemoteNotifier extends AsyncNotifier<Remote> {
  final String remoteId;

  RemoteNotifier(this.remoteId);

  @override
  Future<Remote> build() async {
    final db = ref.watch(dbProvider);
    final offlineRemote = ref.watch(remoteProvider(remoteId)).requireValue!;

    // preload with offline remote
    state = AsyncData(offlineRemote);
    state = AsyncValue.loading();

    final remoteConfig = await ref.watch(remoteConfigProvider(remoteId).future);
    final remote = remoteConfig?.nmap(offlineRemote.parse) ?? offlineRemote;

    // update local name if changed
    if (remote.name != offlineRemote.name) {
      await db
          .into(db.remoteTable)
          .insertOnConflictUpdate(
            RemoteTableCompanion.insert(
              id: remote.id,
              name: remote.name,
            ),
          );
    }

    return remote;
  }

  Future<bool> rename(String name) async {
    final match = Remote.nameRegex.firstMatch(name);
    final remote = state.value;
    if (match == null || remote == null) return false;

    final newRemote = Remote(
      name: name,
      id: remote.id,
      actionConfigs: remote.actionConfigs,
    );

    return await ref
        .read(remoteRequestServiceProvider(remoteId))
        .storeConfig(config: newRemote.serialize())
        .then<bool>(
          (_) {
            state = AsyncData(newRemote);
            return true;
          },
          onError: (_) {
            return false;
          },
        );
  }
}

final remoteNotifierProvider =
    AsyncNotifierProvider.family<RemoteNotifier, Remote, String>(
      RemoteNotifier.new,
      isAutoDispose: false,
    );
