import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

abstract class Styles {
  static const colorBackground = Colors.white;
  static const colorForeground = Colors.black;

  static const colorDanger = Colors.red;
  static const colorWarning = Colors.orange;
  static const colorSuccess = Colors.green;
  static const colorIgnored = Colors.grey;

  static const fontFamily = "Roboto";

  static const contentMaxWidth = 500.0;
  static const standardSpacing = 2.0;

  static const iconFavorite = Symbols.star;
  static const iconNext = Symbols.arrow_forward;
  static const iconPrevious = Symbols.arrow_back;
  static const iconNoData = Symbols.check_indeterminate_small;
  static const iconProgress = Symbols.timeline;
  static const iconCompleted = Symbols.check_circle;
  static const iconRepeat = Symbols.forward_media;
  static const iconEndless = Symbols.flag;
}
