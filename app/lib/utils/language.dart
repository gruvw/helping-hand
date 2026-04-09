import "dart:math";

import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

extension RemoveAll on String {
  String removeAll(Pattern pattern) => replaceAll(pattern, "");
}

extension Capitalize on String {
  String capitalize() {
    if (isEmpty) return "";

    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension Coloren on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);

    return Color.lerp(this, Colors.black, amount)!;
  }

  Color lighten(double amount) {
    assert(amount >= 0 && amount <= 1);

    return Color.lerp(this, Colors.white, amount)!;
  }
}

/// Null map operation extension.
extension NullMap<T extends Object> on T {
  R nmap<R>(R Function(T v) convert) {
    return convert(this);
  }
}

extension RandomListPick<T> on List<T> {
  T pick(Random random) {
    return this[random.nextInt(length)];
  }
}

extension RelativeRoute on BuildContext {
  void goRelative(String relativeLocation) => go("./$relativeLocation");
}
