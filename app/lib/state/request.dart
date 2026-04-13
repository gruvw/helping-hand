import "package:helping_hand/logic/request/fake_request_service.dart";
import "package:helping_hand/logic/request/request_service.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final requestProvider = Provider<RequestService>(
  // (ref) => HttpRequestService(
  //   timeout: Duration(seconds: 10),
  // ),
  (ref) => FakeRequestService(
    requestTime: Duration(seconds: 1),
    failureRate: 0.3,
  ),
);
