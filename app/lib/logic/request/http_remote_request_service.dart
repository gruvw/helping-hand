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

  Future<http.Response> _onTimeout() => throw Exception("connection timed out");

  late final _uri = Uri.parse("http${isHttps ? 's' : ''}://$remoteId.local");

  @override
  Future<void> perform(ActionConfig actionConfig) {
    return http
        .post(_uri.resolve(actionConfig.endpoint))
        .timeout(timeout, onTimeout: _onTimeout);
  }

  @override
  Future<void> reset({required int channel}) {
    return http
        .post(_uri.resolve("/reset?channel=$channel"))
        .timeout(timeout, onTimeout: _onTimeout);
  }

  @override
  Future<void> set({required int channel, required int angle}) {
    return http
        .post(_uri.resolve("/set?channel=$channel&angle=$angle"))
        .timeout(timeout, onTimeout: _onTimeout);
  }

  @override
  Future<String> getConfig() async {
    return http
        .get(_uri.resolve("/config"))
        .timeout(timeout, onTimeout: _onTimeout)
        .then((res) => res.body);
  }

  @override
  Future<void> storeConfig({required String config}) {
    return http
        .post(_uri.resolve("/config"), body: config)
        .timeout(timeout, onTimeout: _onTimeout);
  }
}
