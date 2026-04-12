// not persisted on the app but on the remote,
// aquired by the remote config
class PressButtonConfig {
  final String id;
  final int channel;
  final double angle;
  final int durationMs;

  PressButtonConfig({
    required this.id,
    required this.channel,
    required this.angle,
    required this.durationMs,
  });
}
