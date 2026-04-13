import "package:helping_hand/logic/request/fake_remote_request_service.dart";
import "package:helping_hand/logic/request/remote_request_service.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final remoteRequestServiceProvider =
    Provider.family<RemoteRequestService, String>(
      // (ref) => HttpRequestService(
      //   timeout: Duration(seconds: 10),
      //   remoteName: remoteName,
      // ),
      (ref, remoteName) => FakeRemoteRequestService(
        requestTime: Duration(seconds: 1),
        failureRate: 0.3,
        remoteName: remoteName,
      ),
    );
