import "package:helping_hand/logic/request/fake_remote_request_service.dart";
import "package:helping_hand/logic/request/http_remote_request_service.dart";
import "package:helping_hand/logic/request/remote_request_service.dart";
import "package:helping_hand/state/persistence/kvs/providers.dart";
import "package:helping_hand/static/build_options.dart";
import "package:helping_hand/static/values.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final remoteRequestServiceProvider =
    Provider.family<RemoteRequestService, String>((ref, remoteId) {
      if (BuildOptions.debugFakeRequests) {
        return FakeRemoteRequestService(
          requestTime: Duration(seconds: 1),
          failureRate: 0.4,
          remoteId: remoteId,
        );
      }

      return HttpRemoteRequestService(
        remoteId: remoteId,
        isHttps: ref
            .watch(kvsHttpsProvider)
            .maybeWhen(
              data: (useHttps) => useHttps,
              orElse: () => false,
            ),
        timeout: Values.remoteRequestTimeout,
      );
    });

final remoteConfigProvider = FutureProvider.family<String?, String>(
  (ref, remoteId) {
    final remoteRequestService = ref.watch(
      remoteRequestServiceProvider(remoteId),
    );

    return remoteRequestService.getConfig().then<String?>(
      (config) => config,
      onError: (_) => null,
    );
  },
);
