import 'dart:io';

import 'package:async_task/async_task.dart';
import 'package:libasserest_interface/interface.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path/path.dart' as path;
import 'package:random_string/random_string.dart' as random_string;

import 'property.dart';

File get _dlTestFile {
  while (true) {
    final String tempPath = path.join(
        Platform.isWindows ? Platform.environment["TEMP"]! : "/tmp",
        "asserest_dl_tester",
        random_string.randomAlphaNumeric(96));

    File exportFile = File(tempPath);
    if (!exportFile.existsSync()) {
      return exportFile;
    }
  }
}

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
    } on FTPConnectException {
      return null;
    }
  }

  Future<AsserestResult> _fileAccessTester(FTPConnect ftpConn) async {
    for (AsserestFileAccess afa in property.fileAccess!) {
      if (afa.pathSeg.isEmpty) {
        return AsserestResult.failure;
      }

      final String absAFA = "/${path.joinAll(afa.pathSeg)}";
      final bool cdTest = await ftpConn.changeDirectory(absAFA);
      if (cdTest) {
        await ftpConn.listDirectoryContent();
      } else if (!await ftpConn.downloadFileWithRetry(absAFA, _dlTestFile, pRetryCount: property.tryCount!)) {
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
        ftpConn = await _ftpConn();

        return ftpConn == null
            ? AsserestResult.success
            : AsserestResult.failure;
      }
    } on FTPConnectException {
      return AsserestResult.failure;
    } catch (_) {
      return AsserestResult.error;
    } finally {
      try {
        await ftpConn!.disconnect();
      } catch (__) {}
    }
  }
}
