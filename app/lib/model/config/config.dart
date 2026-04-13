// not persisted on the app but on the remote,
// aquired by the remote config

abstract class ActionConfig {
  static final typeSeparator = ":";
  static final valueSeparator = ",";

  static final namePattern = "[a-zA-Z0-9_\\- ]{1,30}";

  String get name;
  String get endpoint;

  String serialize();
}

class ClickConfig extends ActionConfig {
  static final actionType = "click";

  static ClickConfig? parse(String configLine) {
    final regex = RegExp(
      "^$actionType${ActionConfig.typeSeparator}(${ActionConfig.namePattern}),(\\d+),(\\d+),(\\d+)\$",
    );
    final match = regex.firstMatch(configLine.trim());
    if (match == null) return null;

    return ClickConfig(
      name: match.group(1)!,
      channel: int.parse(match.group(2)!),
      angle: int.parse(match.group(3)!),
      durationMs: int.parse(match.group(4)!),
    );
  }

  @override
  final String name;

  final int channel;
  final int angle;
  final int durationMs;

  ClickConfig({
    required this.name,
    required this.channel,
    required this.angle,
    required this.durationMs,
  });

  @override
  String get endpoint =>
      "/click?channel=$channel&angle=$angle&duration=$durationMs";

  @override
  String serialize() =>
      "$actionType${ActionConfig.typeSeparator}${[channel, angle, durationMs].join(ActionConfig.valueSeparator)}";
}

List<ActionConfig> parseConfig(String config) {
  final parsers = [
    ClickConfig.parse,
  ];

  return config
      .split("\n")
      .map(
        (configLine) =>
            parsers.map((parse) => parse(configLine)).nonNulls.firstOrNull,
      )
      .nonNulls
      .toList();
}

String generateConfig(List<ActionConfig> actions) {
  return actions.map((action) => action.serialize()).join("\n");
}
