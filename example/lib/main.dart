import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter_dynatrace/flutter_dynatrace.dart';
import 'package:flutter_dynatrace/monitored_http_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String requestText = "Loading...";

  ///Initialize Dynatrace. Put here your applicationId and beaconUrl
  Future<void> initializeDynatrace() {
    return FlutterDynatrace.getInstance().startup(
        "applicationId",
        "beaconUrl");
  }

  @override
  void initState() {
    super.initState();
    initializeDynatrace().whenComplete(() {
      testAction();
      testWebRequest(
          "https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=b6907d289e10d714a6e88b30761fae22");
    });
  }

  Future<void> testAction() async {
    var dtx = await FlutterDynatrace.getInstance().enterAction("test");
    await Future.delayed(Duration(seconds: 2));
    dtx.leaveAction();
    return;
  }

  Future<void> testWebRequest(String url) async {
    setState(() {
      requestText = "Loading...";
    });

    var monitoredHttpClient =
        MonitoredHttpClient(http.Client(), FlutterDynatrace.getInstance());
    await monitoredHttpClient.get(url, headers: {MonitoredHttpClient.ACTION_HEADER_NAME: "TEST_API_CALL"});
    setState(() {
      requestText = "Request DONE. Click to do it again!";
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter with Dynatrace"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Text(requestText),
                onTap: () {
                  testWebRequest(
                      "https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=b6907d289e10d714a6e88b30761fae22");
                },
              ),
              SizedBox(
                height: 16,
              ),
              GestureDetector(
                child: FlatButton(
                  child: Text("Click to create test action"),
                  onPressed: () {
                    testAction();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
