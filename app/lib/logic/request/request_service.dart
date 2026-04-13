abstract class RequestService {
  Future<String> getConfig({required String remoteName});
  Future<void> storeConfig({required String config});
  Future<void> click({
    required int channel,
    required double angle,
    required int durationMs,
  });
  Future<void> set({
    required int channel,
    required double angle,
  });
  Future<void> reset({
    required int channel,
  });
}
