import "package:helping_hand/logic/request/remote_request_service.dart";
import "package:helping_hand/model/config/action.dart";
import "package:http/http.dart" as http;

class HttpRemoteRequestService implements RemoteRequestService {
  final String remoteId;
  final bool isHttps;
  final Duration timeout;

  HttpRemoteRequestService({
    required this.remoteId,
    required this.isHttps,
    required this.timeout,
  });

  late final _uri = Uri.parse("http${isHttps ? 's' : ''}://$remoteId.local");

  @override
  Future<String> getConfig() async {
    return http
        .get(_uri)
        .timeout(
          timeout,
          onTimeout: () => throw Exception("connection timed out"),
        )
        .then((res) => res.body);
  }

  @override
  Future<void> perform(ActionConfig actionConfig) {
    // TODO: implement click
    throw UnimplementedError();
  }

  @override
  Future<void> reset({required int channel}) {
    // TODO: implement reset
    throw UnimplementedError();
  }

  @override
  Future<void> set({required int channel, required int angle}) {
    // TODO: implement set
    throw UnimplementedError();
  }

  @override
  Future<void> storeConfig({required String config}) {
    // TODO: implement storeConfig
    throw UnimplementedError();
  }
}
