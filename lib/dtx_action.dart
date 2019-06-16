import 'flutter_dynatrace_api_bridge.dart';

class DTXAction {

  String id;
  DTXActionBridge _apiBridge;

  DTXAction(this.id, this._apiBridge);

//  int endVisit();

  int leaveAction() {
    _apiBridge.leaveAction(this);
  }

  int reportValue(String key, value) {
    _apiBridge.reportValue(this, key, value);
  }

//  int reportEvent(String var1);
//



//
//  int reportError(String var1, int var2);
//
//  int reportError(String var1, Throwable var2);
//
//  int tagRequest(HttpURLConnection var1);
//
//  String getRequestTagHeader();
//
  Future<String> getRequestTag() {
    return _apiBridge.getRequestTag(this);
  }
}