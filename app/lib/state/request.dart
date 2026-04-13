import "package:helping_hand/logic/request/fake_remote_request_service.dart";
import "package:helping_hand/logic/request/remote_request_service.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final remoteRequestServiceProvider =
    Provider.family<RemoteRequestService, String>(
      // (ref) => HttpRequestService(
      //   timeout: Duration(seconds: 10),
      //   remoteName: remoteName,
      // ),
      (ref, remoteId) => FakeRemoteRequestService(
        requestTime: Duration(seconds: 1),
        failureRate: 0.4,
        remoteId: remoteId,
      ),
    );

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
