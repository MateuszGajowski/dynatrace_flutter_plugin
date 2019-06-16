import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter_dynatrace/flutter_dynatrace.dart';
import 'package:flutter_dynatrace/monitoring/monitored_http_client.dart';
import 'package:flutter_dynatrace/monitoring/monitored_widget.dart';

void main() {
  ///Initialize Dynatrace. Put here your applicationId and beaconUrl
  FlutterDynatrace.getInstance().configure(Config(
      applicationId: "applicationId",
      beaconUrl: "beaconUrl"));

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with MonitoredWidget {
  String requestText = "Loading...";

  void initializeDynatrace() {
    window.onReportTimings = (List<FrameTiming> timings) {
      print(timings.toString());
    };
  }

  @override
  void initState() {
    super.initState();
    testAction();
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

  Future<void> testAction() async {
    var dtx = await FlutterDynatrace.getInstance().enterAction("test");
    await Future.delayed(Duration(seconds: 2));
    dtx.leaveAction();
    return;
  }

  Future<void> testWebRequest(String url) async {
    print('testWebRequest');
    setState(() {
      requestText = "Loading...";
    });

    var monitoredHttpClient = MonitoredHttpClient(delegate: http.Client());
    await monitoredHttpClient.get(url, headers: {
      MonitoredHttpClient.ACTION_HEADER_NAME: "TEST_API_CALL",
      MonitoredHttpClient.PARENT_ACTION_HEADER_NAME: getWidgetActionId()
    });
    setState(() {
      requestText = "Request DONE. Click to do it again!";
    });
    callOnDataInitialized();
    return;
  }

  @override
  String actionName() {
    return "DYNATRACE_MAIN_PAGE";
  }

  @override
  void onActionCreated() {
    testWebRequest(
        "https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=b6907d289e10d714a6e88b30761fae22");
  }
}
