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
                  isConnecting=true;
                }), child: const Text('Connect server')),
              ),
              Card(elevation: 10,
                child: TextButton(onPressed: () => setState(() {
                  isExecuteQuery=true;
                }), child: const Text('Add student data')),
              ),
              Card(
                elevation: 10,
                child: TextButton(onPressed: () => setState(() {
                  isSelectQuery=true;
                }), child: const Text('Select student data')),
              ),
              isConnecting?FutureBuilder(
                future: connectServer(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    if(snapshot.data.toString().isNotEmpty){
                      bool status = snapshot.data as bool;
                      return Text(status?'Server connected':'Server failed');
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
              isExecuteQuery?FutureBuilder(
                future: executeQuery(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    if(snapshot.data.toString().isNotEmpty){
                      return const Text('Student data added');
                    }else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            SizedBox(height: 20),
                            Text('Server connection fail')
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
              isSelectQuery?FutureBuilder(
                future: selectQuery(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    if(snapshot.data.toString().isNotEmpty){
                      var data = snapshot.data as List<dynamic>;
                      return Expanded (
                        child: ListView.builder(scrollDirection: Axis.vertical,itemCount: data.length,itemBuilder: (context, index) {
                          Map<Object?,Object?> map = data.elementAt(index) as Map<Object?,Object?>;
                          return ListTile(
                            title: Text(map["name"].toString()),
                            subtitle: Text(map["mark"].toString()),
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

  bool isConnecting=false;
  bool isSelectQuery=false;
  bool isExecuteQuery=false;
  var server='192.168.100.102', database='myDataBase', username='sa', password='sqlr2', port='1433';

  connectServer() async {
    bool status = await _flutterJdbcPlugin.connectServer(server,database,username,password,port)??false;
    return status;
  }

  selectQuery() async {
    var query = "select * from Students";
    var data = await _flutterJdbcPlugin.selectQuery(server, database, username, password, port,query)??[];
    return data;
  }

  int count =1;
  int mark=80;
  executeQuery() async {
    var query = "INSERT INTO Students(name,mark) values ('NAME$count','$mark')";
    count++;
    mark++;
    bool status = await _flutterJdbcPlugin.executeQuery(server,database,username,password,port,query)??false;
    return status;
  }
}
