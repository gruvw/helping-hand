import "dart:async";

import "package:helping_hand/model/config/action.dart";
import "package:helping_hand/model/config/remote.dart";
import "package:helping_hand/state/persistence/database/tables/remote_table.drift.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_request.dart";
import "package:helping_hand/utils/language.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class RemoteNotifier extends AsyncNotifier<Remote?> {
  final String remoteId;

  RemoteNotifier(this.remoteId);

  @override
  Future<Remote?> build() async {
    final db = ref.watch(dbProvider);
    final offlineRemote = ref.watch(localRemoteProvider(remoteId)).requireValue;

    if (offlineRemote == null) {
      return null;
    }

    // preload value with offline remote
    // ignore: invalid_use_of_internal_member
    state = AsyncValue<Remote?>.loading().copyWithPrevious(
      AsyncData(offlineRemote),
    );
    // state = AsyncData(offlineRemote);
    // state = AsyncLoading<Remote?>();

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

    // handle externally removed actions (from tiles)
    final remoteActions = remote.actionConfigs;
    if (remoteActions != null) {
      final remoteActionNames = remoteActions.map((a) => a.name).toSet();

      db.queries.removeStaleActionsFor(
        remoteId: remoteId,
        remoteActionNames: remoteActionNames,
      );
    }

    return remote;
  }

  Future<bool> rename(String name) async {
    final matches = nameRegex.hasMatch(name);
    final remote = state.value;
    if (!matches || remote == null) return false;

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

  Future<bool> addAction(ActionConfig newActionConfig) async {
    final remote = state.value;
    final actionConfigs = remote?.actionConfigs;
    if (remote == null || actionConfigs == null) return false;

    // check action name is unique
    if (actionConfigs.map((a) => a.name).contains(newActionConfig.name)) {
      return false;
    }

    final newRemote = Remote(
      name: remote.name,
      id: remote.id,
      actionConfigs: [
        ...actionConfigs,
        newActionConfig,
      ],
    );

    return await ref
        .read(remoteRequestServiceProvider(remoteId))
        .storeConfig(config: newRemote.serialize())
        .then(
          (_) {
            ref.invalidate(remoteConfigProvider(remoteId));
            return true;
          },
          onError: (_) {
            return false;
          },
        );
  }

  Future<bool> renameAction(
    String previousActionName,
    String newActionName,
  ) async {
    // FIXME (later) currently renaming an action will remove all tiles that were referencing that action because they are using the action name as part of their id, we could remap the tiles locally but that would not work externally, might need to give an id to actions
    final remote = state.value;
    final actionConfigs = remote?.actionConfigs;
    if (remote == null || actionConfigs == null) return false;

    // check new action name is unique
    if (actionConfigs.map((a) => a.name).contains(newActionName)) {
      return false;
    }

    final newRemote = Remote(
      name: remote.name,
      id: remote.id,
      actionConfigs: actionConfigs
          .map(
            (actionConfig) =>
                actionConfig.name == previousActionName &&
                    actionConfig is ClickConfig
                ? ClickConfig(
                    name: newActionName,
                    channel: actionConfig.channel,
                    angle: actionConfig.angle,
                    durationMs: actionConfig.durationMs,
                  )
                : actionConfig,
          )
          .toList(),
    );

    return await ref
        .read(remoteRequestServiceProvider(remoteId))
        .storeConfig(config: newRemote.serialize())
        .then(
          (_) {
            ref.invalidate(remoteConfigProvider(remoteId));
            return true;
          },
          onError: (_) {
            return false;
          },
        );
  }

  Future<bool> removeAction(ActionConfig actionConfig) async {
    final remote = state.value;
    final actionConfigs = remote?.actionConfigs;
    if (remote == null || actionConfigs == null) return false;

    final newRemote = Remote(
      name: remote.name,
      id: remote.id,
      actionConfigs: actionConfigs
          .where((a) => a.name != actionConfig.name)
          .toList(),
    );

    return await ref
        .read(remoteRequestServiceProvider(remoteId))
        .storeConfig(config: newRemote.serialize())
        .then(
          (_) {
            ref.invalidate(remoteConfigProvider(remoteId));
            return true;
          },
          onError: (_) {
            return false;
          },
        );
  }
}

final remoteNotifierProvider =
    AsyncNotifierProvider.family<RemoteNotifier, Remote?, String>(
      RemoteNotifier.new,
      isAutoDispose: false,
    );
