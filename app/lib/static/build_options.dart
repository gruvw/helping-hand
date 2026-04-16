import "package:flutter/foundation.dart";

/// Build option parser
/// Set build option using `--dart-define=<BUILD_OPTION>=<value>`
abstract class BuildOptions {
  /// Delete and create a fresh DB in debug mode if true
  static const debugEraseDB =
      bool.fromEnvironment(
        "DEBUG_ERASE_DB",
        defaultValue: false,
      ) &&
      kDebugMode;

  /// Use fake requests in debug mode if true
  static const debugFakeRequests =
      bool.fromEnvironment(
        "DEBUG_FAKE_REQUESTS",
        defaultValue: false,
      ) &&
      kDebugMode;
}
