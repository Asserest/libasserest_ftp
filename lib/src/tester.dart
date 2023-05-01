import 'package:async_task/async_task.dart';
import 'package:libasserest_interface/interface.dart';
import 'package:ftpconnect/ftpconnect.dart';

import 'property.dart';

class AsserestFtpTestPlatform
    extends AsserestTestPlatform<AsserestFtpProperty> {
  AsserestFtpTestPlatform(super.property, {super.counter});

  @override
  AsyncTask<AsserestFtpProperty, AsserestReport> instantiate(
          AsserestFtpProperty parameters,
          [Map<String, SharedData>? sharedData]) =>
      AsserestFtpTestPlatform(property);

  @override
  AsserestFtpProperty parameters() => property;

  @override
  Future<AsserestResult> runTestProcess() {
    final purl = property.url;
    final port = purl.port == 0 ? 21 : purl.port;

    final ftpConn = FTPConnect(purl.host, 
      port: port,
      user: property.username,
      pass: property.password ?? "",
      timeout: property.timeout.inSeconds,
      securityType: property.security
    );

    throw UnimplementedError();
  }
}
