
import 'flutter_jdbc_plugin_platform_interface.dart';

class FlutterJdbcPlugin {
  Future<String?> getPlatformVersion() {
    return FlutterJdbcPluginPlatform.instance.getPlatformVersion();
  }

  Future<bool?> connectMssql(host,database,username,password,port){
    return FlutterJdbcPluginPlatform.instance.connectMssql(host,database,username,password,port);
  }

  Future<dynamic> selectMssqlQuery(host,database,username,password,port,query){
    return FlutterJdbcPluginPlatform.instance.selectMssqlQuery(host,database,username,password,port,query);
  }
}
