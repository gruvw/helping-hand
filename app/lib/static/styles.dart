import "package:flutter/material.dart";

abstract class Styles {
  static const colorPrimary = Colors.black;
  static const colorSecondary = Colors.white;
  static const colorHint = Color(0xFF6b6b6b);

  static const colorDanger = Colors.red;
  static const colorWarning = Colors.orange;
  static const colorSuccess = Colors.green;
  static const colorIgnored = Colors.grey;

  static const colorFolder = Colors.purple;
  static const colorRemote = Colors.blue;
  static const colorButton = Colors.green;
  static const colorOffline = Colors.grey;

  static const disabledOpacity = 0.4;

  static const fontFamily = "Noto Sans";

  static const textTitle = TextStyle(fontSize: 20);
  static const textNormal = TextStyle(fontSize: 15);
  static const textSub = TextStyle(fontSize: 13);

  static const contentMaxWidth = 500.0;
  static const standardSpacing = 2.0;

  static const iconAdd = Icons.add_outlined;
  static const iconAddTile = Icons.add_box_outlined;
  static const iconAddFolder = Icons.create_new_folder_outlined;
  static const iconEdit = Icons.edit;
  static const iconDelete = Icons.delete;
  static const iconMore = Icons.more_vert;
  static const iconClear = Icons.clear;
  static const iconHidden = Icons.visibility_off;
  static const iconVisible = Icons.visibility;
  static const iconValid = Icons.check;
  static const iconInvalid = Icons.error;
  static const iconSuccess = Icons.check;
  static const iconError = Icons.error;
  static const iconOffline = Icons.cloud_off;
  static const iconFavorite = Icons.star_outline;
  static const iconFolder = Icons.folder_open_outlined;
  static const iconRemote = Icons.settings_remote_outlined;
  static const iconButton = Icons.ads_click_outlined;
  static const iconLeft = Icons.keyboard_arrow_left;
  static const iconRight = Icons.keyboard_arrow_right;
  static const iconUp = Icons.keyboard_arrow_up;
  static const iconDoubleUp = Icons.keyboard_double_arrow_up;
  static const iconDown = Icons.keyboard_arrow_down;
  static const iconDoubleDown = Icons.keyboard_double_arrow_down;
  static const iconLabel = Icons.label_outline;
  static const iconNext = Icons.arrow_forward;
  static const iconPrevious = Icons.arrow_back;
}
