import 'package:flutter/services.dart';

import 'dtx_action.dart';
import 'web_request_timing.dart';

class DynatraceApiBridge {
  static const String METHOD_PREFIX = "DYNATRACE";

  static const MethodChannel _channel =
      const MethodChannel('flutter_dynatrace');

  DTXActionBridge _dtxBridge;
  WebRequestTimingBridge _webRequestTimingBridge;

  DynatraceApiBridge() {
    _dtxBridge = new DTXActionBridge(_channel);
    _webRequestTimingBridge = new WebRequestTimingBridge(_channel);
  }

  Future<int> startup(String applicationId, String beaconUrl) async {
    return await _channel.invokeMethod("${METHOD_PREFIX}_startup",
        {"applicationId": applicationId, "beaconUrl": beaconUrl});
  }

  Future<DTXAction> enterAction(String action) async {
    final String id =
        await _channel.invokeMethod("${METHOD_PREFIX}_enterAction", action);
    return DTXAction(id, _dtxBridge);
  }

  Future<WebRequestTiming> getWebRequestTiming(String requestTag) async {
    final String id = await _channel.invokeMethod(
        "${METHOD_PREFIX}_getWebRequestTiming", requestTag);
    return WebRequestTiming(id, _webRequestTimingBridge);
  }

  Future<String> getRequestTagHeader() async {
    return await _channel.invokeMethod("${METHOD_PREFIX}_getRequestTagHeader");
  }

  DTXActionBridge get dtxBridge => _dtxBridge;
}

class DTXActionBridge {
  static const String METHOD_PREFIX = "DTXAction";
  MethodChannel _channel;

  DTXActionBridge(this._channel);

  Future<int> leaveAction(DTXAction dtxAction) async {
    final int result = await _channel.invokeMethod(
        "${METHOD_PREFIX}_leaveAction", dtxAction.id);
    return result;
  }

  Future<String> getRequestTag(DTXAction dtxAction) async {
    return await _channel.invokeMethod(
        "${METHOD_PREFIX}_getRequestTag", dtxAction.id);
  }
}

class WebRequestTimingBridge {
  static const String METHOD_PREFIX = "WebRequestTiming";
  MethodChannel _channel;

  WebRequestTimingBridge(this._channel);

  Future<int> startWebRequestTiming(WebRequestTiming webRequestTiming) async {
    final int result = await _channel.invokeMethod(
        "${METHOD_PREFIX}_startWebRequestTiming", webRequestTiming.id);
    return result;
  }

  Future<int> stopWebRequestTiming(WebRequestTiming webRequestTiming,
      String url, int respCode, String respPhrase) async {
    return await _channel
        .invokeMethod("${METHOD_PREFIX}_stopWebRequestTiming", {
      "id": webRequestTiming.id,
      "requestUrl": url,
      "respCode": respCode,
      "respPhrase": respPhrase
    });
  }
}
