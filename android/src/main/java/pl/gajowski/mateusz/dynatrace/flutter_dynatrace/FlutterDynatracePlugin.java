package pl.gajowski.mateusz.dynatrace.flutter_dynatrace;

import android.content.Context;

import com.dynatrace.android.agent.DTXAction;
import com.dynatrace.android.agent.Dynatrace;
import com.dynatrace.android.agent.WebRequestTiming;
import com.dynatrace.android.agent.conf.DynatraceConfigurationBuilder;

import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterDynatracePlugin
 */
public class FlutterDynatracePlugin implements MethodCallHandler {

    private Map<String, Object> dynatraceObjects = new HashMap<>();
    private Context context;

    private FlutterDynatracePlugin(Context context) {
        this.context = context;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_dynatrace");
        channel.setMethodCallHandler(new FlutterDynatracePlugin(registrar.context()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "DYNATRACE_startup": {
                final String applicationId = call.argument("applicationId");
                final String beaconUrl = call.argument("beaconUrl");

                final int status = Dynatrace.startup(context,
                        new DynatraceConfigurationBuilder(applicationId, beaconUrl)
                                .buildConfiguration());
                result.success(status);
                break;
            }
            case "DYNATRACE_enterAction": {
                final String id = saveDynatraceObject(enterAction(String.valueOf(call.argument("action")), asString(call.argument("parentActionId"))));
                result.success(id);
                break;
            }
            case "DTXAction_leaveAction": {
                final String id = String.valueOf(call.arguments);
                final DTXAction dtxAction = getAction(id);
                int status = dtxAction.leaveAction();
                removeDynatraceObject(id);
                result.success(status);
                break;
            }
            case "DTXAction_getRequestTag": {
                final DTXAction dtxAction = getAction(String.valueOf(call.arguments));
                final String requestTag = dtxAction.getRequestTag();
                result.success(requestTag);
                break;
            }
            case "DYNATRACE_getWebRequestTiming": {
                final String tag = String.valueOf(call.arguments);
                final String id = saveDynatraceObject(Dynatrace.getWebRequestTiming(tag));
                result.success(id);
                break;
            }
            case "DYNATRACE_getRequestTagHeader":
                final String requestTagHeaderName = Dynatrace.getRequestTagHeader();
                result.success(requestTagHeaderName);
                break;
            case "WebRequestTiming_startWebRequestTiming": {
                final WebRequestTiming webRequestTiming = getWebRequestTiming(String.valueOf(call.arguments));
                final int status = webRequestTiming.startWebRequestTiming();
                result.success(status);
                break;
            }
            case "WebRequestTiming_stopWebRequestTiming": {
                final String id = call.argument("id");
                final WebRequestTiming webRequestTiming = getWebRequestTiming(id);
                final String url = call.argument("requestUrl");
                final Integer respCode = call.argument("respCode");
                final String respPhrase = call.argument("respPhrase");
                final int status;
                try {
                    status = webRequestTiming.stopWebRequestTiming(url, respCode, respPhrase);
                    result.success(status);
                } catch (MalformedURLException e) {
                    result.error(e.getClass().getSimpleName(), e.getMessage(), null);
                }
                removeDynatraceObject(id);
                break;
            }
            default:
                result.notImplemented();
        }
    }

    private DTXAction enterAction(String action, String parentActionId) {
        if (parentActionId == null) {
            return Dynatrace.enterAction(action);
        } else {
            final DTXAction parentAction = getAction(parentActionId);
            return Dynatrace.enterAction(action, parentAction);
        }
    }

    private String saveDynatraceObject(Object object) {
        final String id = generateId();
        dynatraceObjects.put(id, object);
        return id;
    }

    private void removeDynatraceObject(String id) {
        dynatraceObjects.remove(id);
    }

    private DTXAction getAction(String id) {
        final Object object = dynatraceObjects.get(id);
        if (!(object instanceof DTXAction)) {
            throw new IllegalStateException("Invalid object type");
        }

        return (DTXAction) object;
    }

    private WebRequestTiming getWebRequestTiming(String id) {
        final Object object = dynatraceObjects.get(id);
        if (!(object instanceof WebRequestTiming)) {
            throw new IllegalStateException("Invalid object type");
        }

        return (WebRequestTiming) object;
    }

    private String generateId() {
        return UUID.randomUUID().toString();
    }

    private String asString(Object object) {
        return object == null ? null : String.valueOf(object);
    }
}
