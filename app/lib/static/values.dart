abstract class Values {
  static const applicationTitle = "Helping Hand";
  static const databaseName = "hh_db";

  static const maxChannel = 8;
  static const allChannels = 20;

  static const minPositionAngle = 100;
  static const minPressAngleDelta = 2;
  static const maxPressAngle = 150;
  static const minPressAngle = minPositionAngle + minPressAngleDelta;
  static const maxPositionAngle = maxPressAngle - minPressAngleDelta;
}
