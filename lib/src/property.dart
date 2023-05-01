import 'dart:collection';
import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart' show SecurityType;
import 'package:libasserest_interface/interface.dart';
import 'package:quiver/core.dart' as quiver;
import 'package:unique_list/unique_list.dart';

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

class OperatingInDeniedFTPException extends AsserestException {
  OperatingInDeniedFTPException._();

  @override
  String get message => "This operation is illegal when applying testing file in expected failure condition.";

  @override
  String toString() => "OperatingInDeniedFTPException: $message";
}

class AsserestFileAccess {
  final UnmodifiableListView<String> pathSeg;
  final bool success;

  const AsserestFileAccess._(this.pathSeg, this.success);

  factory AsserestFileAccess(String path, bool success) {
    final pathUri = Uri.file(path, windows: false);

    if (!pathUri.hasAbsolutePath) {
      // Unaccept relative path
      throw NonAbsolutePathException._(pathUri);
    }

    return AsserestFileAccess._(
        UnmodifiableListView(pathUri.pathSegments), success);
  }

  @override
  int get hashCode => quiver.hashObjects(pathSeg) >> pathSeg.length % 3;

  @override
  bool operator ==(Object other) =>
      other is AsserestFileAccess && hashCode == other.hashCode;
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

  final UniqueList<AsserestFileAccess>? fileAccess;

  const AsserestFtpProperty._(
      this.url,
      this.accessible,
      this.timeout,
      this.tryCount,
      this.username,
      this.password,
      this.security,
      this.fileAccess);
}

class FTPPropertyParseProcessor
    extends PropertyParseProcessor<AsserestFtpProperty> {
  const FTPPropertyParseProcessor();

  @override
  AsserestFtpProperty createProperty(Uri url, Duration timeout, bool accessible,
      int? tryCount, UnmodifiableMapView<String, dynamic> additionalProperty) {
    final SecurityType security = SecurityType.values
        .singleWhere((e) => e.name == additionalProperty["security"]);

    final List<Map<String, dynamic>>? access = additionalProperty["access"];
    if (access != null && !accessible) {
      throw OperatingInDeniedFTPException._();
    }

    return AsserestFtpProperty._(
        url,
        accessible,
        timeout,
        tryCount,
        additionalProperty["username"] ?? "anonymous",
        additionalProperty["password"],
        security,
        access != null
            ? UniqueList.from(
                access.map(
                    (e) => AsserestFileAccess(e["target_path"], e["success"])),
                growable: false,
                nullable: false,
                strict: false)
            : null);
  }

  @override
  Set<String> get supportedSchemes => const <String>{"ftp"};
}
