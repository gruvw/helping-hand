import "package:collection/collection.dart";
import "package:helping_hand/model/config/action.dart";
import "package:helping_hand/utils/language.dart";

class Remote {
  static final nameRegex = RegExp("^$namePattern\$");

  final String id; // hh-0001
  final String name;
  // final String icon;
  final List<ActionConfig>? actionConfigs;

  Remote({
    required this.id,
    required this.name,
    this.actionConfigs,
  });

  Remote.fromData({
    required this.id,
    required this.name,
  }) : actionConfigs = null;

  bool get isOnline => actionConfigs != null;

  /// Used to convent an offline remote to a fully featured remote by providing a config.
  /// Will return `null` if the config is not valid.
  Remote? parse(String config) {
    final (configName, configActions) = config.splitOnce("\n");

    final name = configName.isEmpty ? this.name : configName;

    return Remote(
      id: id,
      name: name,
      actionConfigs: configActions?.nmap(parseConfigActions) ?? [],
    );
  }

  String serialize() {
    return "$name\n${generateConfigActions(actionConfigs!)}";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Remote &&
        other.id == id &&
        other.name == name &&
        const ListEquality().equals(other.actionConfigs, actionConfigs);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    actionConfigs == null ? null : Object.hashAll(actionConfigs!),
  );
}
