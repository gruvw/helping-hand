import "dart:math";

import "package:flutter/widgets.dart";
import "package:helping_hand/logic/request/remote_request_service.dart";
import "package:helping_hand/model/config/action.dart";
import "package:helping_hand/utils/language.dart";

class FakeRemoteRequestService implements RemoteRequestService {
  static final List<String> _connectedRemotes = ["hh-0001", "hh-0002"];
  static final Map<String, String> _configs = {
    _connectedRemotes[0]: [
      "My Remote 1",
      "click:my first button,1,102,100",
      "click:my other button,1,102,100",
      "hold:0 hold second button,2,102",
      "release:1 release second button,2",
    ].join("\n"),
    _connectedRemotes[1]: "Kitchen remote",
  };

  final Random _random = Random();

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
    return _configs[remoteId]!;
  }

  @override
  Future<void> storeConfig({required String config}) async {
    await _fakeRequest("store config:\n$config\n");
    _configs[remoteId] = config;
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

  @override
  Future<void> play({required String payload}) =>
      _fakeRequest("playing ir payload $payload");
}
