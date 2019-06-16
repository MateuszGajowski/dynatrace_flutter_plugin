import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import '../dtx_action.dart';
import '../flutter_dynatrace.dart';

///Responsible for monitoring user feeling of loading pages (first full load).
///For example use this when you want measure time from initState to rendered screen with all data.
///You should call #onDataInitialized after you fetched all needed data.
///This is for measure time between showing first frame of screen (ex. loading screen) to final view.
///IMPORTANT! If you want to measure all API requests with this action as parent add header as follows and create your requests in #onActionCreated:<br>
/// ```dart
/// MonitoredHttpClient.PARENT_ACTION_HEADER_NAME: getWidgetActionId()
/// ```
mixin MonitoredWidget<T extends StatefulWidget> on State<T> {
  final Logger log = new Logger('MonitoredWidget');

  DTXAction widgetAction;
  bool _loadCompleted = false;

  @override
  void initState() {
    super.initState();
    _onInitState();
  }

  Future<void> _onInitState() async {
    log.info("Widget onInit called. Sending enterAction for=" + _resolveActionName());
    if (!_loadCompleted) {
      widgetAction =
      await FlutterDynatrace.getInstance().enterAction(_resolveActionName());
      onActionCreated();
    }
    log.info("END Widget onInit called. Sending enterAction for=" + _resolveActionName());

    return;
  }

  ///Call this method when all data is fetched and everything is ready to show user final
  ///rendered page with all data.
  ///This method will measure till next build time<br>
  ///Leave action will be called only once
  void callOnDataInitialized() {
    if (widgetAction != null && !_loadCompleted) {
      _loadCompleted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        log.info("Widget built. Sending leaveAction for=" + _resolveActionName());
        widgetAction.leaveAction();
        widgetAction = null;
      });
    }
  }

  ///Action name to log. If not provided - widget name
  String actionName();

  ///It is safe to call requests here. Parent action is created
  void onActionCreated();

  String _resolveActionName() {
    String action = actionName();
    if (action == null || action.isEmpty) {
      action = runtimeType.toString();
    }

    return action;
  }

  String getWidgetActionId() {
    return widgetAction?.id;
  }
}
