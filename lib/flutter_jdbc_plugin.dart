
import 'flutter_jdbc_plugin_platform_interface.dart';

class FlutterJdbcPlugin {
  Future<String?> getPlatformVersion() {
    return FlutterJdbcPluginPlatform.instance.getPlatformVersion();
  }

  Future<bool?> connectServer(server,database,username,password,port) async{
    return FlutterJdbcPluginPlatform.instance.connectServer(server,database,username,password,port);
  }

  Future<dynamic> selectQuery(server,database,username,password,port,query) async{
    return FlutterJdbcPluginPlatform.instance.selectQuery(server,database,username,password,port,query);
  }

  Future<dynamic> executeQuery(server,database,username,password,port,query) async{
    return FlutterJdbcPluginPlatform.instance.executeQuery(server,database,username,password,port,query);
  }
}
