import "package:helping_hand/model/config/action.dart";

abstract class RemoteRequestService {
  Future<String> getConfig();
  Future<void> storeConfig({required String config});

  Future<void> perform(ActionConfig actionConfig);

  Future<void> set({
    required int channel,
    required double angle,
  });
  Future<void> reset({
    required int channel,
  });
}
