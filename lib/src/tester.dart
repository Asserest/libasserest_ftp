import 'dart:io';

import 'package:async_task/async_task.dart';
import 'package:libasserest_interface/interface.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path/path.dart' as path;
import 'package:random_string/random_string.dart' as random_string;

import 'property.dart';

String get _testTempDLDir => path.join(
    Platform.isWindows ? Platform.environment["TEMP"]! : "/tmp",
    "asserest_dl_tester");

/// Test platform for asserting FTP protocol
class AsserestFtpTestPlatform
    extends AsserestTestPlatform<AsserestFtpProperty> {
  /// Construct a FTP tester with given property.
  AsserestFtpTestPlatform(super.property, {super.counter});

  static Future<File> get _dlFileObj async {
    Directory tempDLDir = Directory(_testTempDLDir);
    tempDLDir = await tempDLDir.createTemp("asrftp");

    File f =
        File(path.join(tempDLDir.path, random_string.randomAlphaNumeric(64)));
    return await f.create(exclusive: true);
  }

  @override
  AsyncTask<AsserestFtpProperty, AsserestReport> instantiate(
          AsserestFtpProperty parameters,
          [Map<String, SharedData>? sharedData]) =>
      AsserestFtpTestPlatform(property);

  @override
  AsserestFtpProperty parameters() => property;

  Future<FTPConnect?> _ftpConn() async {
    final purl = property.url;
    final port = purl.port == 0 ? 21 : purl.port;

    final ftp = FTPConnect(purl.host,
        port: port,
        user: property.username,
        pass: property.password ?? "",
        timeout: property.timeout.inSeconds,
        securityType: property.security);

    try {
      await ftp.connect();
      return ftp;
    } on FTPConnectException {
      return null;
    }
  }

  Future<AsserestResult> _fileAccessTester(FTPConnect ftpConn) async {
    for (AsserestFileAccess afa in property.fileAccess!) {
      final String absAFA = "/${path.joinAll(afa.ftpPath)}";
      final bool cdTest = await ftpConn.changeDirectory(absAFA);

      if (cdTest) {
        // It is directory
        await ftpConn.listDirectoryContent();
      } else if (!await ftpConn.downloadFileWithRetry(absAFA, await _dlFileObj,
          pRetryCount: property.tryCount!)) {
        // Download files but
        return AsserestResult.failure;
      }
    }

    return AsserestResult.success;
  }

  @override
  Future<AsserestResult> runTestProcess() async {
    FTPConnect? ftpConn = null;

    try {
      if (property.accessible) {
        // Accessible case
        for (int count = 0; count < property.tryCount!; count++) {
          ftpConn = await _ftpConn();
          if (ftpConn != null) {
            break;
          }
        }

        if (ftpConn == null) {
          return AsserestResult.failure;
        } else if (property.fileAccess == null) {
          return AsserestResult.success;
        }

        return _fileAccessTester(ftpConn);
      } else {
        // Inaccessible case
        ftpConn = await _ftpConn();

        return ftpConn == null
            ? AsserestResult.success
            : AsserestResult.failure;
      }
    } on FTPConnectException {
      // Assume failed if FtpConnect throw exceptions
      return AsserestResult.failure;
    } catch (_) {
      // Other error exception which likely not related with FtpConnect
      return AsserestResult.error;
    } finally {
      // Ensure disconnected
      try {
        await ftpConn!.disconnect();
      } catch (__) {}
    }
  }
}
