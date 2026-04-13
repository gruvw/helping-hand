import "package:helping_hand/logic/request/request_service.dart";
import "package:http/http.dart" as http;

class HttpRequestService implements RequestService {
  final Duration timeout;

  HttpRequestService({required this.timeout});

  @override
  Future<String> getConfig({required String remoteName}) async {
    final uri = Uri.parse("http://$remoteName.local");

    return http
        .get(uri)
        .timeout(
          timeout,
          onTimeout: () => throw Exception("connection timed out"),
        )
        .then((res) => res.body);
  }

  @override
  Future<void> click({
    required int channel,
    required double angle,
    required int durationMs,
  }) {
    // TODO: implement click
    throw UnimplementedError();
  }

  @override
  Future<void> reset({required int channel}) {
    // TODO: implement reset
    throw UnimplementedError();
  }

  @override
  Future<void> set({required int channel, required double angle}) {
    // TODO: implement set
    throw UnimplementedError();
  }

  @override
  Future<void> storeConfig({required String config}) {
    // TODO: implement storeConfig
    throw UnimplementedError();
  }
}
