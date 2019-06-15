import 'dart:async';

import 'dtx_action.dart';
import 'flutter_dynatrace_api_bridge.dart';
import 'web_request_timing.dart';

class FlutterDynatrace {
  static FlutterDynatrace _instance;
  static DynatraceApiBridge _apiBridge = DynatraceApiBridge();
  bool initialized = false;

  static FlutterDynatrace getInstance() {
    if (_instance == null) {
      _instance = new FlutterDynatrace._internal();
    }

    return _instance;
  }

  FlutterDynatrace._internal();

  Future<int> startup(String applicationId, String beaconUrl) async {
    if (!initialized) {
      var result = await _apiBridge.startup(applicationId, beaconUrl);
      initialized = true;
      return result;
    }

    return Future.value(0);
  }

  Future<DTXAction> enterAction(String action) async {
    _checkIfInitialized();
    return _apiBridge.enterAction(action);
  }

  Future<WebRequestTiming> getWebRequestTiming(String requestTag) async {
    _checkIfInitialized();
    return _apiBridge.getWebRequestTiming(requestTag);
  }

  Future<String> getRequestTagHeader() async {
    _checkIfInitialized();
    return _apiBridge.getRequestTagHeader();
  }

  void _checkIfInitialized() {
    if (!initialized) {
      throw new Exception("Dynatrace SDK not initalized. Call startup method!");
    }
  }
}
