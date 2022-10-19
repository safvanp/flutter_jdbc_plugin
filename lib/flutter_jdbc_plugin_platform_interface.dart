import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_jdbc_plugin_method_channel.dart';

abstract class FlutterJdbcPluginPlatform extends PlatformInterface {
  /// Constructs a FlutterJdbcPluginPlatform.
  FlutterJdbcPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterJdbcPluginPlatform _instance = MethodChannelFlutterJdbcPlugin();

  /// The default instance of [FlutterJdbcPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterJdbcPlugin].
  static FlutterJdbcPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterJdbcPluginPlatform] when
  /// they register themselves.
  static set instance(FlutterJdbcPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> connectMssql(String host,String database,String username,String password,String port) {
    throw UnimplementedError('connectMssql() has not been implemented.');
  }

  Future<dynamic> selectMssqlQuery(String host,String database,String username,String password,String port,query) {
    throw UnimplementedError('selectMssqlQuery() has not been implemented.');
  }
}
