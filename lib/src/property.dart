import 'dart:collection';

import 'package:ftpconnect/ftpconnect.dart' show SecurityType;
import 'package:libasserest_interface/interface.dart';

class AsserestFTPProperty implements AsserestProperty {
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

  const AsserestFTPProperty._(this.url, this.accessible, this.timeout,
      this.tryCount, this.username, this.password, this.security);
}

class FTPPropertyParseProcessor
    extends PropertyParseProcessor<AsserestFTPProperty> {
  const FTPPropertyParseProcessor();

  @override
  AsserestFTPProperty createProperty(Uri url, Duration timeout, bool accessible,
      int? tryCount, UnmodifiableMapView<String, dynamic> additionalProperty) {
    final SecurityType security = SecurityType.values
        .singleWhere((e) => e.name == additionalProperty["security"]);

    return AsserestFTPProperty._(
        url,
        accessible,
        timeout,
        tryCount,
        additionalProperty["username"] ?? "anonymous",
        additionalProperty["password"],
        security);
  }

  @override
  Set<String> get supportedSchemes => const <String>{"ftp"};
}
