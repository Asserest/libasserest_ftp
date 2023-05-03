import 'dart:collection';

import 'package:ftpconnect/ftpconnect.dart' show SecurityType;
import 'package:libasserest_interface/interface.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart' as quiver;
import 'package:unique_list/unique_list.dart';

/// This exception will be thrown when applying relative path
/// as paramater which expected in absolute form.
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

/// Exclusive exception for applying [AsserestFileAccess] when
/// [AsserestFtpProperty.accessible] is `false` which causing
/// violation in logic.
class OperatingInDeniedFTPException extends AsserestException {
  OperatingInDeniedFTPException._();

  @override
  String get message => "This operation is illegal when applying testing file in expected failure condition.";

  @override
  String toString() => "OperatingInDeniedFTPException: $message";
}

/// An entity of asserting file access for each path and determine
/// it is accessible by listing content or download it for path to 
/// directory or files accordingly.
@sealed
class AsserestFileAccess {
  /// A segment of the path
  final UnmodifiableListView<String> pathSeg;

  /// Determine it can be operated without error.
  /// 
  /// The methods of testing [pathSeg] followed as below:
  /// |pathSeg's type|Testing method|
  /// |:--------------:|:-------------|
  /// |Directory|Invoke `list` command|
  /// |Files|Download to local storage (as a cache)|
  final bool success;

  const AsserestFileAccess._(this.pathSeg, this.success);

  /// Construct a file access property for [path] and determine
  /// is operated [success] or not.
  /// 
  /// [path] must be in absolute form or throws [NonAbsolutePathException]
  /// if not obey.
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

  /// Username of accessing FTP server.
  /// 
  /// If this field omitted in configuration script, `anonymous`
  /// will be parsed automatically.
  final String username;

  /// Password of username for granted access.
  /// 
  /// **WARNING: ASSEREST DOES NOT LIABLE FOR ANY DATA LEAK DUE TO IMPROPER IMPLEMENTATION ON TESTING**
  final String? password;

  /// Define [SecurityType] for accessing FTP server.
  final SecurityType security;

  /// Optional field for [accessible] configuration that determine each path given
  /// can be operated normally.
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

/// [PropertyParseProcessor] for constructing FTP configuration.
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
        url.replace(pathSegments: const []),
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
