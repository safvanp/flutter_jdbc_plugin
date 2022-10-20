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
    when (call.method) {
        "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        "connectServer" -> {
          val arguments = call.arguments as HashMap<String, String>
          connectServer(arguments["server"].toString(),arguments["database"].toString(),arguments["username"].toString(),arguments["password"].toString(),arguments["port"].toString(),result)
        }
        "selectQuery" -> {
          val arguments = call.arguments as HashMap<String, String>
          selectQuery(arguments["server"].toString(),arguments["database"].toString(),arguments["username"].toString(),arguments["password"].toString(),arguments["port"].toString(),arguments["query"].toString(),result)
        }
        "executeQuery" -> {
          val arguments = call.arguments as HashMap<String, String>
          executeQuery(arguments["server"].toString(),arguments["database"].toString(),arguments["username"].toString(),arguments["password"].toString(),arguments["port"].toString(),arguments["query"].toString(),result)
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  var connectionClass: ConnectionClass? = null
  var connection: Connection? = null

  private fun connectServer(server:String, database:String,  username:String, password:String,  port:String,result:Result) {
    if(isConUrl(server,database,username,password)) {
      try {
        connectionClass = ConnectionClass()
        connection = connectionClass!!.ConnectMSSql("$server:$port", database, username, password)
        if (connection != null) {
//          result.error("mssql","Failed to connection server",null)
          result.success(false)
        } else {
          result.success(true)
        }
      } catch (ex: Exception) {
//      result.error("error", "error mssql",ex.message)
        connection?.close()
        result.success(false)
      } finally {
        try {
          if (connection != null) {
            if (!connection!!.isClosed()) {
              connection!!.close();
            }
          }
        } catch (ex: ClassNotFoundException) {
          ex.printStackTrace();
        }
      }
      connection?.close()
    } else{
      result.success(false)
    }
  }

  private fun selectQuery(server:String, database:String,  username:String, password:String,  port:String,query:String,result:Result) {
    if(isConUrl(server,database,username,password)) {
      connectionClass = ConnectionClass()
      try {
        connection = connectionClass!!.ConnectMSSql("$server:$port", database, username, password)
        if (connection != null) {
          var rs: ResultSet
          val statement = connection!!.prepareStatement(query)
          rs = statement.executeQuery()
          val list: MutableList<Map<String, Any>> = ArrayList()
          var cols: ResultSetMetaData = rs.metaData;
          while (rs.next()) {
            val map: MutableMap<String, Any> = HashMap()
            var j = 0
            for (i in 1 until cols.columnCount+1) {
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
        connection?.close()
        result.success(false)
      } finally {
        try {
          if (connection != null) {
            if (!connection!!.isClosed()) {
              connection!!.close();
            }
          }
        } catch (ex: ClassNotFoundException) {
          ex.printStackTrace();
        }
      }
      connection?.close()
    } else {
      result.success(false)
    }
  }

  private fun executeQuery(server:String, database:String,  username:String, password:String,  port:String,query:String,result:Result) {
    if(isConUrl(server,database,username,password)) {
      connectionClass = ConnectionClass()
      try {
        connection = connectionClass!!.ConnectMSSql("$server:$port", database, username, password)
        if (connection != null) {
          val statement = connection!!.createStatement()
          statement.executeUpdate(query)
          result.success(true)
        } else {
          result.success(false)
        }
      } catch (ex: Exception) {
//      result.error("error", "error mssql",ex.message)
        connection?.close()
        result.success(false)
      } finally {
        try {
          if (connection != null) {
            if (!connection!!.isClosed()) {
              connection!!.close();
            }
          }
        } catch (ex: ClassNotFoundException) {
          ex.printStackTrace();
        }
      }
      connection?.close()
    } else {
      result.success(false)
    }
  }

  private fun isConUrl(server: String, database: String, username: String, password: String): Boolean {
    if (server == null || server.trim() == "") {
      return false
    } else if (database == null || database.trim() == "") {
      return false
    } else if (username == null || database.trim() == "") {
      return false
    } else if (password == null) {
      return false
    }
    return  true
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
