import "dart:math";

import "package:flutter/widgets.dart";
import "package:helping_hand/logic/request/remote_request_service.dart";
import "package:helping_hand/model/config/action.dart";
import "package:helping_hand/utils/language.dart";

class FakeRemoteRequestService implements RemoteRequestService {
  static final List<String> _connectedRemotes = ["hh-0001", "hh-0002"];

  final Random _random = Random();
  String _config = "alex";

  final String remoteId;
  final Duration requestTime;
  final double failureRate;

  FakeRemoteRequestService({
    required this.remoteId,
    required this.requestTime,
    required this.failureRate,
  });

  Future<void> _fakeRequest(String debugMsg) async {
    debugPrint("Sending fake requets: $debugMsg");

    await Future.delayed(_random.nextDuration(requestTime, requestTime * 2));

    if (!_connectedRemotes.contains(remoteId)) {
      throw Exception("could not reach fake remote");
    }

    if (_random.nextDouble() < failureRate) {
      throw Exception("fake request failed");
    }
  }

  @override
  Future<String> getConfig() async {
    await _fakeRequest("get config");
    return _config;
  }

  @override
  Future<void> storeConfig({required String config}) async {
    await _fakeRequest("store config:\n$config\n");
    _config = config;
  }

  @override
  Future<void> perform(ActionConfig actionConfig) => _fakeRequest(
    "performing: ${actionConfig.name} -> ${actionConfig.endpoint}",
  );

  @override
  Future<void> set({required int channel, required int angle}) =>
      _fakeRequest("setting channel $channel to angle $angle");

  @override
  Future<void> reset({required int channel}) =>
      _fakeRequest("reseting channel $channel");
}
