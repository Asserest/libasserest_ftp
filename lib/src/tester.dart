import 'package:async_task/async_task.dart';
import 'package:libasserest_interface/interface.dart';
import 'package:ftpconnect/ftpconnect.dart';

import 'property.dart';

class AsserestFtpTestPlatform extends AsserestTestPlatform<AsserestFtpProperty> {
  AsserestFtpTestPlatform(super.property);

  @override
  AsyncTask<AsserestFtpProperty, AsserestReport> instantiate(AsserestFtpProperty parameters, [Map<String, SharedData>? sharedData]) {
    // TODO: implement instantiate
    throw UnimplementedError();
  }

  @override
  AsserestFtpProperty parameters() => property;

  @override
  Future<AsserestResult> runTestProcess() {
    // TODO: implement runTestProcess
    throw UnimplementedError();
  }
}