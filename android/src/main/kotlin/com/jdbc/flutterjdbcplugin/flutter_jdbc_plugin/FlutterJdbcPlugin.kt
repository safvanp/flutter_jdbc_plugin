package com.jdbc.flutterjdbcplugin.flutter_jdbc_plugin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.sql.Connection
import java.sql.ResultSet
import java.sql.ResultSetMetaData

/** FlutterJdbcPlugin */
class FlutterJdbcPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_jdbc_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if(call.method == "sqlConnect"){
      val arguments = call.arguments as HashMap<String, String>
      val host = arguments["host"] as String
      val database = arguments["database"] as String
      val username = arguments["username"] as String
      val password = arguments["password"] as String
      val port = arguments["port"] as String
      connectSql(host,database,username,password,port,result)
    } else if(call.method == "sqlSelectQuery"){
      val arguments = call.arguments as HashMap<String, String>
      val host = arguments["host"] as String
      val database = arguments["database"] as String
      val username = arguments["username"] as String
      val password = arguments["password"] as String
      val port = arguments["port"] as String
      val query = arguments["query"] as String
      sqlSelectQuery(host,database,username,password,port,query,result)
    } else {
      result.notImplemented()
    }
  }

  var connectionClass: ConnectionClass? = null
  var con: Connection? = null

  private fun connectSql(host:String, database:String,  username:String, password:String,  port:String,result:Result) {
    connectionClass = ConnectionClass()
    try {
      con = connectionClass!!.ConnectMSSql("$host:$port", database, username, password)
      if (con != null) {
//        result.error("mssql","Connection fail","mssql connection fail")
        result.success(false)
      } else {
        result.success(true)
      }
    } catch (ex: Exception) {
//      result.error("error", "error mssql",ex.message)
      result.success(false)
    }
  }

  private fun sqlSelectQuery(host:String, database:String,  username:String, password:String,  port:String,query:String,result:Result) {
    connectionClass = ConnectionClass()
    try {
      con = connectionClass!!.ConnectMSSql("$host:$port", database, username, password)
      if (con != null) {
//        result.error("mssql","Connection fail","mssql connection fail")
        var rs: ResultSet
        val stmt = con!!.prepareStatement(query)
        rs = stmt.executeQuery()
        val list: MutableList<Map<String, Any>> = ArrayList()
        var cols:ResultSetMetaData = rs.metaData;
        while (rs.next()) {
          val map: MutableMap<String, Any> = HashMap()
          var j =0
          for(i in 1 until cols.columnCount){
            map[cols.getColumnName(i)] = rs.getString(cols.getColumnName(i))
          }
          list.add(map)
          j++;
        }
        result.success(list)
      } else {
        result.success(false)
      }
    } catch (ex: Exception) {
//      result.error("error", "error mssql",ex.message)
      result.success(false)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
