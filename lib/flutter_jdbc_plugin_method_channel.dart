import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_jdbc_plugin_platform_interface.dart';

/// An implementation of [FlutterJdbcPluginPlatform] that uses method channels.
class MethodChannelFlutterJdbcPlugin extends FlutterJdbcPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_jdbc_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> connectMssql(String host,String database,String username,String password,String port) async {
    final result = await methodChannel.invokeMethod<bool>('sqlConnect',{'host':host,'database':database,'username':username,'password':password,'port':port});
    return result;
  }

  @override
  Future<dynamic> selectMssqlQuery(String host,String database,String username,String password,String port,query) async {
    final result = await methodChannel.invokeMethod<dynamic>('sqlSelectQuery',{'host':host,'database':database,'username':username,'password':password,'port':port,'query':query});
    return result;
  }

}
