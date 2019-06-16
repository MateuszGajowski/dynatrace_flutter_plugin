# flutter_dynatrace

A Flutter plugin which lets you call OneAgent SDK from your Flutter 


This is just a beginning.
This project now is in state of POC it needs more development, polishing and documentation.

#### What is in POC for now:
- Android support only
- Dynatrace methods bridge implemented:
-- startup
-- enterAction (also with parent)
-- leaveAction
-- getRequestTag
-- getWebRequestTiming
-- getRequestTagHeader
-- startWebRequestTiming
-- stopWebRequestTiming
- Convenient HTTP Client (MonitoredHttpClient) for your API calls. You can use it directly or create adapter for Dio (or every other HTTP Client wrapper)
- MonitoredWidget
- Simple demo. Just provide your dynatrace data to get it ready
