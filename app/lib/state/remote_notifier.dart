import "dart:async";

import "package:helping_hand/logic/request/remote_request_service.dart";
import "package:helping_hand/model/config/config.dart";
import "package:helping_hand/model/data/remote.dart";
import "package:helping_hand/state/request.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class RemoteNotifier extends AsyncNotifier<Remote> {
  final String remoteName;

  RemoteNotifier(this.remoteName);

  late RemoteRequestService _remoteRequestService;

  @override
  Future<Remote> build() async {
    _remoteRequestService = ref.watch(remoteRequestServiceProvider(remoteName));

    final actionConfigs = await _remoteRequestService.getConfig().then(
      (config) => parseConfig(config),
      onError: (_) => null,
    );

    return Remote(
      name: remoteName,
      actionConfigs: actionConfigs,
    );
  }
}

final remoteNotifierProvider =
    AsyncNotifierProvider.family<RemoteNotifier, Remote, String>(
      RemoteNotifier.new,
      isAutoDispose: false,
    );
