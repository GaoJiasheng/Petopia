import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opt-in compile flag for internal TestFlight utilities.
///
/// App Store builds intentionally omit this define, allowing the compiler to
/// remove the control, its action path, and the native method-channel call.
const bool testFlightToolsCompiled = bool.fromEnvironment(
  'PETOPIA_TESTFLIGHT_TOOLS',
  defaultValue: false,
);

/// Internal builds can exercise the complete support flow without charging.
///
/// App Store builds omit this define, so their purchase path always remains
/// backed by StoreKit.
const bool simulatedSupportPurchasesCompiled = bool.fromEnvironment(
  'PETOPIA_SIMULATED_SUPPORT_PURCHASES',
  defaultValue: false,
);

/// Requiring both flags prevents a lone build define from replacing StoreKit.
const bool internalSimulatedSupportPurchasesEnabled =
    testFlightToolsCompiled && simulatedSupportPurchasesCompiled;

abstract interface class DistributionEnvironment {
  Future<bool> isTestFlight();
}

class NativeDistributionEnvironment implements DistributionEnvironment {
  static const _channel = MethodChannel('cn.gavingao.petopia/distribution');

  @override
  Future<bool> isTestFlight() async {
    if (!testFlightToolsCompiled) return false;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      return await _channel.invokeMethod<bool>('isTestFlight') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

final distributionEnvironmentProvider = Provider<DistributionEnvironment>(
  (_) => NativeDistributionEnvironment(),
);

final isTestFlightProvider = FutureProvider<bool>((ref) async {
  if (!testFlightToolsCompiled) return false;
  return ref.watch(distributionEnvironmentProvider).isTestFlight();
});
