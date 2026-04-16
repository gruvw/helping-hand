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
  static const iconWeight = 700.0;

  static const textTitle = TextStyle(fontSize: 20);
  static const textNormal = TextStyle(fontSize: 15);
  static const textSub = TextStyle(fontSize: 13);

  static const contentMaxWidth = 500.0;
  static const standardSpacing = 2.0;

  static const iconAdd = Symbols.add;
  static const iconAddTile = Symbols.add_box;
  static const iconAddFolder = Symbols.create_new_folder;
  static const iconEdit = Symbols.edit;
  static const iconDelete = Symbols.delete;
  static const iconMore = Symbols.more_vert;
  static const iconClear = Symbols.clear;
  static const iconHidden = Symbols.visibility_off;
  static const iconVisible = Symbols.visibility;
  static const iconValid = Symbols.check;
  static const iconInvalid = Symbols.error;
  static const iconSuccess = Symbols.check;
  static const iconError = Symbols.error;
  static const iconOffline = Symbols.cloud_off;
  static const iconFavorite = Symbols.star;
  static const iconLeft = Symbols.keyboard_arrow_left;
  static const iconRight = Symbols.keyboard_arrow_right;
  static const iconUp = Symbols.keyboard_arrow_up;
  static const iconDoubleUp = Symbols.keyboard_double_arrow_up;
  static const iconDown = Symbols.keyboard_arrow_down;
  static const iconDoubleDown = Symbols.keyboard_double_arrow_down;
  static const iconLabel = Symbols.label;
  static const iconNext = Symbols.arrow_forward;
  static const iconPrevious = Symbols.arrow_back;
}
