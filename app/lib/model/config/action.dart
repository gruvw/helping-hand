import "package:collection/collection.dart";

// not persisted on the app but on the remote,
// aquired by the remote config

const namePattern = "[a-zA-Z0-9_\\- ]{1,30}";
final nameRegex = RegExp("^$namePattern\$");

sealed class ActionConfig {
  static final typeSeparator = ":";
  static final valueSeparator = ",";

  String get name;
  String get endpoint;

  String serialize();
}

class ClickConfig extends ActionConfig {
  static final actionType = "click";

  static ClickConfig? parse(String configLine) {
    final regex = RegExp(
      "^$actionType${ActionConfig.typeSeparator}($namePattern),(\\d+),(\\d+),(\\d+)\$",
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
      "$actionType${ActionConfig.typeSeparator}$name${ActionConfig.valueSeparator}${[channel, angle, durationMs].join(ActionConfig.valueSeparator)}";
}

class HoldConfig extends ActionConfig {
  static final actionType = "hold";

  static HoldConfig? parse(String configLine) {
    final regex = RegExp(
      "^$actionType${ActionConfig.typeSeparator}($namePattern)${ActionConfig.valueSeparator}(\\d+)${ActionConfig.valueSeparator}(\\d+)\$",
    );
    final match = regex.firstMatch(configLine.trim());
    if (match == null) return null;

    return HoldConfig(
      name: match.group(1)!,
      channel: int.parse(match.group(2)!),
      angle: int.parse(match.group(3)!),
    );
  }

  @override
  final String name;

  final int channel;
  final int angle;

  HoldConfig({
    required this.name,
    required this.channel,
    required this.angle,
  });

  @override
  String get endpoint => "/set?channel=$channel&angle=$angle";

  @override
  String serialize() =>
      "$actionType${ActionConfig.typeSeparator}$name${ActionConfig.valueSeparator}${[channel, angle].join(ActionConfig.valueSeparator)}";
}

class ReleaseConfig extends ActionConfig {
  static final actionType = "release";

  static ReleaseConfig? parse(String configLine) {
    final regex = RegExp(
      "^$actionType${ActionConfig.typeSeparator}($namePattern)${ActionConfig.valueSeparator}(\\d+)\$",
    );
    final match = regex.firstMatch(configLine.trim());
    if (match == null) return null;

    return ReleaseConfig(
      name: match.group(1)!,
      channel: int.parse(match.group(2)!),
    );
  }

  @override
  final String name;

  final int channel;

  ReleaseConfig({
    required this.name,
    required this.channel,
  });

  @override
  String get endpoint => "/reset?channel=$channel";

  @override
  String serialize() =>
      "$actionType${ActionConfig.typeSeparator}$name${ActionConfig.valueSeparator}$channel";
}

List<ActionConfig> parseConfigActions(String config) {
  final parsers = [
    ClickConfig.parse,
    HoldConfig.parse,
    ReleaseConfig.parse,
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

String generateConfigActions(List<ActionConfig> actions) {
  return actions.map((action) => action.serialize()).join("\n");
}
