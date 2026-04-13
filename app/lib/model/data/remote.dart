import "package:helping_hand/model/config/config.dart";

class Remote {
  // TODO remote display name
  final String name; // hh-0001
  // final String icon;
  final List<ActionConfig>? actionConfigs;

  Remote({
    required this.name,
    this.actionConfigs,
  });

  Remote.fromData({
    required this.name,
  }) : actionConfigs = null;

  bool get isOnline => actionConfigs != null;
}
