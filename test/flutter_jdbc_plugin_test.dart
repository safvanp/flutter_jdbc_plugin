import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_jdbc_plugin/flutter_jdbc_plugin.dart';
import 'package:flutter_jdbc_plugin/flutter_jdbc_plugin_platform_interface.dart';
import 'package:flutter_jdbc_plugin/flutter_jdbc_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterJdbcPluginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterJdbcPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool?> connectMssql(String host, String database, String username, String password, String port) {
    // TODO: implement connectMssql
    throw UnimplementedError();
  }

  @override
  Future selectMssqlQuery(String host, String database, String username, String password, String port, query) {
    // TODO: implement selectMssqlQuery
    throw UnimplementedError();
  }
}

void main() {
  final FlutterJdbcPluginPlatform initialPlatform = FlutterJdbcPluginPlatform.instance;

  test('$MethodChannelFlutterJdbcPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterJdbcPlugin>());
  });

  test('getPlatformVersion', () async {
    FlutterJdbcPlugin flutterJdbcPlugin = FlutterJdbcPlugin();
    MockFlutterJdbcPluginPlatform fakePlatform = MockFlutterJdbcPluginPlatform();
    FlutterJdbcPluginPlatform.instance = fakePlatform;

    expect(await flutterJdbcPlugin.getPlatformVersion(), '42');
  });
}
