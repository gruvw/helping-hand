import "package:flutter/material.dart";

class EventNotifier extends ChangeNotifier {
  void fire() => notifyListeners();
}
