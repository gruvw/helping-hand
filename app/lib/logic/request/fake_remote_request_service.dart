import "dart:math";

import "package:helping_hand/logic/request/remote_request_service.dart";
import "package:helping_hand/model/config/config.dart";
import "package:helping_hand/utils/language.dart";

class FakeRemoteRequestService implements RemoteRequestService {
  static final List<String> _connectedRemotes = ["hh-0001", "hh-0002"];

  final Random _random = Random();
  String _config = "";

  final String remoteName;
  final Duration requestTime;
  final double failureRate;

  FakeRemoteRequestService({
    required this.remoteName,
    required this.requestTime,
    required this.failureRate,
  });

  Future<void> _fakeRequest() async {
    await Future.delayed(_random.nextDuration(requestTime, requestTime * 2));

    if (!_connectedRemotes.contains(remoteName)) {
      throw Exception("could not reach fake remote");
    }

    if (_random.nextDouble() < failureRate) {
      throw Exception("fake request failed");
    }
  }

  @override
  Future<String> getConfig() async {
    await _fakeRequest();
    return _config;
  }

  @override
  Future<void> storeConfig({required String config}) async {
    await _fakeRequest();
    _config = config;
  }

  @override
  Future<void> perform(ActionConfig actionConfig) => _fakeRequest();

  @override
  Future<void> set({required int channel, required double angle}) =>
      _fakeRequest();

  @override
  Future<void> reset({required int channel}) => _fakeRequest();
}
