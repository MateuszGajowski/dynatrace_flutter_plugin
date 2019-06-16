import 'dart:async';

import 'dtx_action.dart';
import 'flutter_dynatrace_api_bridge.dart';
import 'web_request_timing.dart';
import 'package:logging/logging.dart';

class FlutterDynatrace {
  static FlutterDynatrace _instance;
  static DynatraceApiBridge _apiBridge = DynatraceApiBridge();

  Config _config;
  bool initialized = false;

  static FlutterDynatrace getInstance() {
    if (_instance == null) {
      _instance = new FlutterDynatrace._internal();
    }

    return _instance;
  }

  FlutterDynatrace._internal();

  void configure(Config config) {
    this._config = config;
    _initializeLogging();
  }

  Future<DTXAction> enterAction(String action, {String parentActionId}) async {
    await _initializeIfNeeded();
    return _apiBridge.enterAction(action, parentActionId: parentActionId);
  }

  Future<WebRequestTiming> getWebRequestTiming(String requestTag) async {
    await _initializeIfNeeded();
    return _apiBridge.getWebRequestTiming(requestTag);
  }

  Future<String> getRequestTagHeader() async {
    await _initializeIfNeeded();
    return _apiBridge.getRequestTagHeader();
  }

  Future<int> _initializeIfNeeded() async {
    return _initialize(_config.applicationId, _config.beaconUrl);
  }

  Future<int> _initialize(String applicationId, String beaconUrl) async {
    if (!initialized) {
      _checkIfConfigured();
      var result = await _apiBridge.startup(applicationId, beaconUrl);
      initialized = true;
      return result;
    }

    return Future.value(0);
  }

  void _initializeLogging() {
    if (_config.loggingEnabled) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((LogRecord rec) {
        if (_config.logger != null) {
          _config.logger(rec.message);
        } else {
          print('${rec.level.name}: ${rec.time}: ${rec.message}');
        }
      });
    }
  }

  void _checkIfConfigured() {
    if (_config == null) {
      throw new Exception("Dynatrace SDK not configured. Call #config method!");
    }
  }
}

class Config {
  final String applicationId;
  final String beaconUrl;
  final Function logger;
  final bool loggingEnabled;

  ///Warning this causes small overhead for CPU and framerate<br>
  ///Also this might cause heavy increase in action sending
  final bool reportTimings;

  Config(
      {this.applicationId,
      this.beaconUrl,
      this.logger,
      this.loggingEnabled = true,
      this.reportTimings = false})
      : assert(applicationId != null),
        assert(beaconUrl != null);
}
