import 'package:http/http.dart' as http;

import 'flutter_dynatrace.dart';

/// Currently if you want to tag your request add header with key x-dynatrace-action-name
class MonitoredHttpClient extends http.BaseClient {
  static const ACTION_HEADER_NAME = "x-dynatrace-action-name";
  static const DEFAULT_ACTION_NAME = "API_REQUEST";

  http.Client _delegate;
  FlutterDynatrace _flutterOneAgent;

  MonitoredHttpClient(this._delegate, this._flutterOneAgent);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async   {
    var webAction  = await _flutterOneAgent.enterAction(_getActionName(request));
    var requestTag = await webAction.getRequestTag();
    var timing = await _flutterOneAgent.getWebRequestTiming(requestTag);
    var requestTagHeaderName = await _flutterOneAgent.getRequestTagHeader();

    request.headers[requestTagHeaderName] = requestTag;

    timing.startWebRequestTiming();

    return _delegate.send(request).then((response) {
      timing.stopWebRequestTiming(request.url.toString(), response.statusCode, "");
      webAction.leaveAction();
      return response;
    }).catchError((ex) {
        timing.stopWebRequestTiming(request.url.toString(), -1, ex.toString());
        throw ex;
    });
  }

  String _getActionName(http.BaseRequest request) {
      if (request.headers.containsKey(ACTION_HEADER_NAME)) {
        return request.headers[ACTION_HEADER_NAME];
      }

      return DEFAULT_ACTION_NAME;
  }

}