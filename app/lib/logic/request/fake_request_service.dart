import "dart:math";

import "package:helping_hand/logic/request/request_service.dart";
import "package:helping_hand/utils/language.dart";

class FakeRequestService implements RequestService {
  final Random _random = Random();
  String config = "";

  final Duration requestTime;
  final double failureRate;

  FakeRequestService({
    required this.requestTime,
    required this.failureRate,
  });

  Future<void> _fakeRequest() async {
    await Future.delayed(_random.nextDuration(requestTime, requestTime * 2));

    if (_random.nextDouble() < failureRate) {
      throw Exception("fake request failed");
    }
  }

  @override
  Future<String> getConfig({required String remoteName}) async {
    await _fakeRequest();
    return config;
  }

  @override
  Future<void> storeConfig({required String config}) async {
    await _fakeRequest();
    this.config = config;
  }

  @override
  Future<void> click({
    required int channel,
    required double angle,
    required int durationMs,
  }) => _fakeRequest();

  @override
  Future<void> set({required int channel, required double angle}) =>
      _fakeRequest();

  @override
  Future<void> reset({required int channel}) => _fakeRequest();
}
