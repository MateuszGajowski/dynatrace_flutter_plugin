import 'flutter_dynatrace_api_bridge.dart';

class WebRequestTiming {

  String id;
  WebRequestTimingBridge _apiBridge;

  WebRequestTiming(this.id, this._apiBridge);

//  int endVisit();

  int startWebRequestTiming() {
    _apiBridge.startWebRequestTiming(this);
  }

  int stopWebRequestTiming(String url, int respCode, String respPhrase) {
    _apiBridge.stopWebRequestTiming(this, url, respCode, respPhrase);
  }

//  int reportEvent(String var1);
//
//  int reportValue(String var1, int var2);
//
//  int reportValue(String var1, double var2);
//
//  int reportValue(String var1, String var2);
//
//  int reportError(String var1, int var2);
//
//  int reportError(String var1, Throwable var2);
//
//  int tagRequest(HttpURLConnection var1);
//
//  String getRequestTagHeader();
//
//  String getRequestTag();
}