import 'dart:collection';
import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart' show SecurityType;
import 'package:libasserest_interface/interface.dart';

class PathUnresolvedException extends AsserestException implements FormatException {
  final dynamic _locationInfo;

  PathUnresolvedException._(this._locationInfo);

  @override
  final int? offset = null;

  static String _printSrc(dynamic info) {
    if (info is File) {
      return info.path;
    }

    return "$info";
  }

  @override
  String get source {
    if (_locationInfo is Iterable) {
      StringBuffer buf = StringBuffer();
      _locationInfo.forEach((element) => buf.writeln(_printSrc(element)));

      return buf.toString();
    }

    return _printSrc(_locationInfo);
  }

}

class AsserestFileProperties {
  final List<Uri> read;

  final List<File> write;

  final List<Uri> delete;

  const AsserestFileProperties._(this.read, this.write, this.delete);

  factory AsserestFileProperties({List<Uri> read = const <Uri>[], List<File> write = const <File>[], List<Uri> delete = const <Uri>[]}) {
    final List<dynamic> invalidProperty = []..addAll(read.where((element) => !element.hasAbsolutePath))
      ..addAll(write.where((element) => !element.isAbsolute))
      ..addAll(delete.where((element) => !element.hasAbsolutePath));

    if (invalidProperty.isNotEmpty) {
      throw PathUnresolvedException._(invalidProperty);
    }

    return AsserestFileProperties._(read, write, delete);
  }
}

class AsserestFtpProperty implements AsserestProperty {
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

  final AsserestFileProperties fileProperties;

  const AsserestFtpProperty._(this.url, this.accessible, this.timeout,
      this.tryCount, this.username, this.password, this.security, this.fileProperties);
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
        AsserestFileProperties()
        );
  }

  @override
  Set<String> get supportedSchemes => const <String>{"ftp"};
}
