import 'dart:collection';
import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart' show SecurityType;
import 'package:libasserest_interface/interface.dart';
import 'package:quiver/core.dart' as quiver;

class NonAbsolutePathException extends AsserestException
    implements FormatException {
  final Uri _relativeUri;

  NonAbsolutePathException._(this._relativeUri);

  @override
  int? get offset => null;

  @override
  String get message => "Unable to located file by using relative path";

  @override
  get source => _relativeUri;

  @override
  String toString() {
    StringBuffer buf = StringBuffer();
    buf
      ..write("NonAbsolutePathException: ")
      ..write(message)
      ..writeln("Sources: ")
      ..write("$source");

    return buf.toString();
  }
}

abstract class FTPFilesOperation {
  const FTPFilesOperation._();

  Uri get targetPath;
  bool get success;

  static void _verifyAbsUri(Iterable<Uri> uris) {
    final invalidUri = uris.where((element) => !element.hasAbsolutePath);
    if (invalidUri.isNotEmpty) {
      throw NonAbsolutePathException._(invalidUri.first);
    }
  }
}

class FTPSingleFileOperation implements FTPFilesOperation {
  @override
  final Uri targetPath;

  @override
  final bool success;

  FTPSingleFileOperation({required this.targetPath, required this.success}) {
    FTPFilesOperation._verifyAbsUri([targetPath]);
  }

  @override
  int get hashCode => quiver.hash2(
      targetPath.toFilePath(windows: false), targetPath.toString());
}

class FTPDoubleFilesOperation implements FTPFilesOperation {
  final Uri sourcePath;

  @override
  final Uri targetPath;

  @override
  final bool success;

  FTPDoubleFilesOperation(
      {required this.sourcePath,
      required this.targetPath,
      required this.success}) {
    FTPFilesOperation._verifyAbsUri([sourcePath, targetPath]);
  }

  @override
  int get hashCode => quiver.hash2(
      sourcePath.toFilePath(windows: false),
      targetPath.toFilePath(windows: false));
}

class AsserestFileProperties {
  
}

class AsserestFtpProperty implements AsserestProperty {
  /// The [Uri.host] of testing [url].
  ///
  /// This assertion will ignore applied path if provided.
  @override
  final Uri url;

  @override
  final bool accessible;

  @override
  final Duration timeout;

  @override
  final int? tryCount;

  final String username;

  final String? password;

  final SecurityType security;

  final AsserestFileProperties? fileProperties;

  const AsserestFtpProperty._(
      this.url,
      this.accessible,
      this.timeout,
      this.tryCount,
      this.username,
      this.password,
      this.security,
      this.fileProperties);
}

class FTPPropertyParseProcessor
    extends PropertyParseProcessor<AsserestFtpProperty> {
  const FTPPropertyParseProcessor();

  @override
  AsserestFtpProperty createProperty(Uri url, Duration timeout, bool accessible,
      int? tryCount, UnmodifiableMapView<String, dynamic> additionalProperty) {
    final SecurityType security = SecurityType.values
        .singleWhere((e) => e.name == additionalProperty["security"]);

    return AsserestFtpProperty._(
        url,
        accessible,
        timeout,
        tryCount,
        additionalProperty["username"] ?? "anonymous",
        additionalProperty["password"],
        security,
        null);
  }

  @override
  Set<String> get supportedSchemes => const <String>{"ftp"};
}
