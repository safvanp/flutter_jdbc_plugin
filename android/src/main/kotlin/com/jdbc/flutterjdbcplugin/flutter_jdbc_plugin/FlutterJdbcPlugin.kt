package com.jdbc.flutterjdbcplugin.flutter_jdbc_plugin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import org.json.JSONArray
import org.json.JSONObject
import java.sql.*

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

  private fun connectServer(server:String, database:String,  username:String, password:String,  port:String,result:Result) {
    if(isConUrl(server,database,username,password)) {
      var connection: Connection? = null
      try {
        val conString =
          "jdbc:jtds:sqlserver://$server:$port;databaseName=$database;user=$username;password=$password;"
        runBlocking {
          connection = async { connectDriver(conString) }.await()
          if (connection != null) {
            result.success(true)
          } else {
            result.success(false)
          }
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
      var connection: Connection? = null
      try {
        val conString =
          "jdbc:jtds:sqlserver://$server:$port;databaseName=$database;user=$username;password=$password;"
        runBlocking {
          connection = withContext(Dispatchers.Default) {
            connectDriver(conString)
          }
          if (connection != null) {
            runBlocking {
              val list: MutableList<Map<String,Any>> = ArrayList()
              GlobalScope.async {
                try{
                  val statement = connection!!.createStatement()
                  var rs: ResultSet = statement.executeQuery(query)
                  var metadata: ResultSetMetaData = rs.metaData;
                  while (rs.next()) {
                    val map: MutableMap<String,Any> = HashMap()
                    for (i in 1..metadata.columnCount) {
                      map[metadata.getColumnName(i)]=rs.getObject(metadata.getColumnName(i))
                    }
                    list.add(map)
                  }
                }  catch (ex: ClassNotFoundException) {
                  result.error("class",ex.message,null)
                }
              }.await()
              result.success(list)
            }
          } else {
            result.success(false)
          }
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
      var connection: Connection? = null
      try {
        val conString =
          "jdbc:jtds:sqlserver://$server:$port;databaseName=$database;user=$username;password=$password;"
        runBlocking {
          connection = async { connectDriver(conString) }.await()
          if (connection != null) {
            val statement = connection!!.createStatement()
            val ret = statement.executeUpdate(query)
            if (ret >= 1) {
              result.success(true)
            } else {
              result.success(false)
            }
          } else {
            result.success(false)
          }
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
    if (server == null || server.trim() == ""||database == null || database.trim() == ""||username == null || username.trim() == ""||password == null) {
      return false
    } else {
      return try {
          val className = "net.sourceforge.jtds.jdbc.Driver"
          Class.forName(className).newInstance()
        true
      } catch (ex: ClassNotFoundException) {
          println("catch : $ex");
        false
      }
    }
    return  true
  }

  private suspend fun connectDriver(
    jdbcConnectionString: String
  ): Connection? {
    return GlobalScope.async {
      return@async DriverManager.getConnection(
        jdbcConnectionString
      )
    }.await();
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
