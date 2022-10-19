import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_jdbc_plugin/flutter_jdbc_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterJdbcPlugin = FlutterJdbcPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterJdbcPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              Card(elevation: 10,
                child: TextButton(onPressed: () => setState(() {
                  isLoading=true;
                }), child: const Text('Connect Mssql')),
              ),
              Card(
                elevation: 10,
                child: TextButton(onPressed: () => setState(() {
                  isLoading1=true;
                }), child: const Text('Select data Mssql')),
              ),
              isLoading?FutureBuilder(
                future: connectMssql(),
                builder: (context, snapshot) {
                if(snapshot.hasData){
                  if(snapshot.data.toString().isNotEmpty){
                    return const Text('Mssql connected');
                  }else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          SizedBox(height: 20),
                          Text('Mssql connection fail')
                        ],
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return AlertDialog(
                    title: const Text(
                      'An Error Occurred!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                    content: Text(
                      "${snapshot.error}",
                      style: const TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('This may take some time..')
                    ],
                  ),
                );
              },):const Text(''),
              isLoading1?FutureBuilder(
                future: sqlExecute(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    if(snapshot.data.toString().isNotEmpty){
                      var data = snapshot.data as List<dynamic>;
                      return Expanded (
                        child: ListView.builder(scrollDirection: Axis.vertical,itemCount: data.length,itemBuilder: (context, index) {
                          Map<Object?,Object?> map = data.elementAt(index) as Map<Object?,Object?>;
                          return ListTile(
                            title: Text(map["ItemName"].toString()),
                            subtitle: Text(map["Qty"].toString()),
                          );
                        }),
                      );
                    }else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            SizedBox(height: 20),
                            Text('Mssql connection fail')
                          ],
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return AlertDialog(
                      title: const Text(
                        'An Error Occurred!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                      content: Text(
                        "${snapshot.error}",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'Go Back',
                            style: TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('This may take some time..')
                      ],
                    ),
                  );
                },):const Text(''),
            ],
          ),
        ),
      ),
    );
  }

  bool isLoading=false;
  bool isLoading1=false;
  var host='192.168.100.102', database='RUBY', username='sa', password='sqlr2', port='1433';

  connectMssql() async {
    bool status = await _flutterJdbcPlugin.connectMssql(host,database,username,password,port)??false;
    return status;
  }

  sqlExecute() async {
    var query = "select * from Stock";
    var data = await _flutterJdbcPlugin.selectMssqlQuery(host, database, username, password, port,query)??[];
    return data;
  }
}
