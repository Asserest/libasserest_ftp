/// An initializer library for guiding setup process with [asserestFtpSetup].
library initializer;

import 'package:libasserest_interface/interface.dart';
import 'src/property.dart' show AsserestFtpProperty, FtpPropertyParseProcessor;
import 'src/tester.dart';

/// Guard check to prevent [asserestFtpSetup] called more than once.
bool _asserestFtpSetup = false;

/// Quick setup method for automatically binding [FtpPropertyParseProcessor]
/// and [AsserestFtpTestPlatform] into [AsserestPropertyParser] and
/// [AsserestTestAssigner] respectively.
///
/// This method must be callel at **ONCE** only, calling multiple time will
/// throw [StateError] to prevent duplicated input, even though you have been
/// removed those [PropertyParseProcessor] and [AsserestTestPlatform] already.
void asserestFtpSetup({bool counter = false}) {
  if (_asserestFtpSetup) {
    throw StateError(
        "This method should be call once only. If you removed property parse processor or test platform, please add them manually.");
  }

  _asserestFtpSetup = true;
  AsserestPropertyParser().define(FtpPropertyParseProcessor());
  AsserestTestAssigner().assign(
      AsserestFtpProperty,
      (property) => AsserestFtpTestPlatform(property as AsserestFtpProperty,
          counter: counter));
}
