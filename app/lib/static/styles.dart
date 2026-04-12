import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

abstract class Styles {
  static const colorPrimary = Colors.black;
  static const colorSecondary = Colors.white;
  static const colorHint = Color(0xFF6b6b6b);

  static const colorDanger = Colors.red;
  static const colorWarning = Colors.orange;
  static const colorSuccess = Colors.green;
  static const colorIgnored = Colors.grey;

  static const disabledOpacity = 0.4;

  static const fontFamily = "Noto Sans";
  static const iconWeight = 600.0;

  static const textTitle = TextStyle(fontSize: 20);
  static const textNormal = TextStyle(fontSize: 15);
  static const textSub = TextStyle(fontSize: 13);

  static const contentMaxWidth = 500.0;
  static const standardSpacing = 2.0;

  static const iconAdd = Symbols.add;
  static const iconEdit = Symbols.edit;
  static const iconClear = Symbols.clear;
  static const iconHidden = Symbols.visibility_off;
  static const iconVisible = Symbols.visibility;
  static const iconValid = Symbols.check;
  static const iconInvalid = Symbols.clear;
  static const iconFavorite = Symbols.star;
  static const iconNext = Symbols.arrow_forward;
  static const iconPrevious = Symbols.arrow_back;
  static const iconNoData = Symbols.check_indeterminate_small;
  static const iconProgress = Symbols.timeline;
  static const iconCompleted = Symbols.check_circle;
  static const iconRepeat = Symbols.forward_media;
  static const iconEndless = Symbols.flag;
}
