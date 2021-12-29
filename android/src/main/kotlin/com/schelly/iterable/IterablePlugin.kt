package com.schelly.iterable

import androidx.annotation.NonNull
import android.app.Application
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.net.Uri;
import android.content.Intent

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.iterable.iterableapi.*
import com.iterable.iterableapi.FlutterInternalIterable

import org.json.JSONObject
import kotlin.collections.*
//import kotlin.reflect.*

/** IterablePlugin */
class IterablePlugin: FlutterPlugin, MethodCallHandler, IterableUrlHandler, IterableCustomActionHandler, IterableInAppHandler, IterableAuthHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var context: Context? = null
  private var inAppResponse = IterableInAppHandler.InAppResponse.SHOW;

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "iterable")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> initialize(call, result)
      "setEmail" -> setEmail(call)
      "getEmail" -> getEmail(result)
      "updateEmail" -> updateEmail(call, result)
      "setUserId" -> setUserId(call)
      "getUserId" -> getUserId(result)
      "updateUser" -> updateUser(call, result)
      "setEmailAndUserId" -> setEmailAndUserId(call, result)
      "getAttributionInfo" -> getAttributionInfo(result)
      "setAttributionInfo" -> setAttributionInfo(call)
      "updateSubscriptions" -> updateSubscriptions(call)
      "trackEvent" -> trackEvent(call)
      "updateCart" -> updateCart(call)
      "trackPurchase" -> trackPurchase(call)
      "getLastPushPayload" -> getLastPushPayload(result)
      "disableDeviceForCurrentUser" -> disableDeviceForCurrentUser()
      "wakeApp" -> wakeApp()
      "setAutoDisplayPaused" -> setAutoDisplayPaused(call)
      else -> result.onMain().notImplemented()
  }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun initialize(call: MethodCall, result: Result) {
    val args = call.arguments as Map<*, *>
    val configMap = args[CONFIG] as Map<*, *>
    val apiKey = args[API_KEY] as String
    val version = args[VERSION] as String
    
    toIterableConfig(configMap)?.let { config ->

      val urlHandlerPresent = configMap[URL_HANDLER_PRESENT] as? Boolean ?: false
      val customActionHandlerPresent = configMap[CUSTOM_ACTION_HANDLER_PRESENT] as? Boolean ?: false
      val inAppHandlerPresent = configMap[INAPP_HANDLER_PRESENT] as? Boolean ?: false
      val authHandlerPresent = configMap[AUTH_HANDLER_PRESENT] as? Boolean ?: false
  
      if (urlHandlerPresent) {
        config.setUrlHandler(this)
      }
  
      if (customActionHandlerPresent) {
        config.setCustomActionHandler(this)
      }
  
      if (inAppHandlerPresent) {
        config.setInAppHandler(this)
      }
  
      if (authHandlerPresent) {
        config.setAuthHandler(this)
      }

      context?.let { context -> 
        Handler(Looper.getMainLooper()).post {
          IterableApi.initialize(context, apiKey, config.build())
          Log.d(BuildConfig.TAG, "Instance Initialized")
          IterableApi.getInstance().setDeviceAttribute(SDK_VERSION, version)
          result.onMain().success(true)
        }
      }
    //   events.subscribe(EmitterListeners(channel))
    } ?: run {
        Log.e(BuildConfig.TAG, "Failed to initialize instance.")
        Handler(Looper.getMainLooper()).post {
            result.onMain().success(false) // todo: should this use .error() instead?
        }
    }
  }

  private fun setEmail(call: MethodCall) {
    val email = call.argument<String>("email")
    IterableApi.getInstance().setEmail(email)
  }

  private fun getEmail(result: Result) {
    result.onMain().success(FlutterInternalIterable.getEmail() ?: "")
  }

  private fun updateEmail(call: MethodCall, result: Result) {
    val email = call.argument<String>("email").let { it } ?: return 
    
    IterableApi.getInstance().updateEmail(email, IterableHelper.SuccessHandler { data ->
      result.onMain().success("updateEmail to $email was successful.")
      }, IterableHelper.FailureHandler { reason, data ->
        result.onMain().success("updateEmail to $email failed. Reason: $reason") // todo: should this use .error() instead?
    })
  }

  private fun setUserId(call: MethodCall) {
    val userId = call.argument<String>("userId")
    IterableApi.getInstance().setUserId(userId)
  }

  private fun getUserId(result: Result) {
    result.onMain().success(FlutterInternalIterable.getUserId() ?: "")
  }

  private fun updateUser(call: MethodCall, result: Result) {
    val dataFields = call.argument<Map<*, *>>("dataFields").let { it } ?: return
    val mergeNestedObjects = call.argument<Boolean>("mergeNestedObjects") ?: true
    
    IterableApi.getInstance().updateUser(JSONObject(dataFields), mergeNestedObjects)
    result.onMain().success("updateUser successful with dataFields: ${dataFields.toString()}")
  }

  private fun setEmailAndUserId(call: MethodCall, result: Result) {
    val email = call.argument<String>("email").let { it } ?: return
    val userId = call.argument<String>("userId").let { it } ?: return 
    
    IterableApi.getInstance().updateEmail(email, IterableHelper.SuccessHandler {  
      IterableApi.getInstance().updateUser(JSONObject().put("userId", userId), true)
        IterableApi.getInstance().setUserId(userId)
        result.onMain().success("setEmailAndUserId successful")
    }, IterableHelper.FailureHandler { reason, data -> 
      result.onMain().success("setEmailAndUserId to $email and $userId failed. Reason: $reason")
    })
  }

  private fun updateSubscriptions(call: MethodCall) {
    val campaignId = call.argument<Int>("campaignId")
    val templateId = call.argument<Int>("templateId")
    val emailListIds = call.argument<List<Int>>("emailListIds")?.toTypedArray()
    val unsubscribedChannelIds = call.argument<List<Int>>("unsubscribedChannelIds")?.toTypedArray()
    val unsubscribedMessageTypeIds = call.argument<List<Int>>("unsubscribedMessageTypeIds")?.toTypedArray()
    val subscribedMessageTypeIds = call.argument<List<Int>>("subscribedMessageTypeIds")?.toTypedArray()

    IterableApi.getInstance().updateSubscriptions(emailListIds,
                                                  unsubscribedChannelIds,
                                                  unsubscribedMessageTypeIds,
                                                  subscribedMessageTypeIds,
                                                  campaignId,
                                                  templateId)
  }

  private fun getAttributionInfo(result: Result) {
    val attrInfo = IterableApi.getInstance().getAttributionInfo()
    val attrInfoMap = attrInfo?.toJSONObject()?.toFriendlyMap()
    result.onMain().success(attrInfoMap ?: HashMap<String, Any>())
  }

  private fun setAttributionInfo(call: MethodCall) {
    val attrInfo = call.argument<Map<*,*>>("attributionInfo").let { it } ?: return
    val attrInfoJSON = JSONObject(attrInfo)
    val attributionInfo = IterableAttributionInfo.fromJSONObject(attrInfoJSON).let { it } ?: return

    FlutterInternalIterable.setAttributionInfo(attributionInfo!!)
  }

  private fun trackEvent(call: MethodCall) {
    val eventName = call.argument<String>("eventName").let { it } ?: return
    val dataFields = call.argument<Map<*, *>>("dataFields")
    
    eventName?.let { name ->
      IterableApi.getInstance().track(eventName, JSONObject(dataFields))
    }
  }
  
  private fun updateCart(call: MethodCall) {
    val items = call.argument<List<Map<*,*>>>("items").let { it } ?: return
    val commerceItems = items.map { item -> commerceItemFromMap(item) }.filter { x: CommerceItem? -> x != null }

    IterableApi.getInstance().updateCart(commerceItems)
  }

  private fun trackPurchase(call: MethodCall) {
    val total = call.argument<Double>("total").let { it } ?: return
    val items = call.argument<List<Map<*,*>>>("items").let { it } ?: return
    val dataFields = call.argument<Map<*, *>>("dataFields")

    val commerceItems = items.map { item -> commerceItemFromMap(item) }.filter { x: CommerceItem? -> x != null }

    IterableApi.getInstance().trackPurchase(total, commerceItems, JSONObject(dataFields))
  }

  private fun getLastPushPayload(result: Result) {
    val payloadData = IterableApi.getInstance().getPayloadData()
    var payloadMap = HashMap<String, Any?>()

    payloadData?.let { data -> 
      data.keySet()?.forEach { key -> 
        payloadMap.put(key, data.get(key))
      }
    }

    result.onMain().success(payloadMap)
  }

  private fun disableDeviceForCurrentUser() {
    IterableApi.getInstance().disablePush()
  }

  private fun trackPushOpen(call: MethodCall) {}

  private fun trackInAppOpen(call: MethodCall) {}

  private fun trackInAppClick(call: MethodCall) {}

  private fun trackInAppClose(call: MethodCall) {}

  private fun inAppConsume(call: MethodCall) {}

  private fun getInAppMessages(result: Result) {}

  private fun showMessage(call: MethodCall, result: Result) {}

  private fun setReadForMessage(call: MethodCall) {}

  private fun removeMessage(call: MethodCall) {}

  private fun getHtmlInAppContent(call: MethodCall, result: Result) {}

  private fun setAutoDisplayPaused(call: MethodCall) {
    val paused = call.argument<Boolean>("paused") ?: false
    Handler(Looper.getMainLooper()).post {
      IterableApi.getInstance().getInAppManager().setAutoDisplayPaused(paused);
    }
  }

  private fun setInAppShowResponse(call: MethodCall) {}

  private fun handleAppLink(call: MethodCall, result: Result) {}

  private fun setAuthToken(call: MethodCall) {}

  private fun wakeApp() {
    val launcherIntent = getMainActivityIntent().let { it } ?: return 
    val pkgManager = context?.getPackageManager().let { it } ?: return 
    launcherIntent!!.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
    
    if (launcherIntent!!.resolveActivity(pkgManager) != null) {
        context?.startActivity(launcherIntent!!);
    }
  }

  private fun getMainActivityIntent(): Intent? {
    val appContext = context?.getApplicationContext().let { it } ?: return null
    val pkgManager = context?.getPackageManager().let { it } ?: return null
    var intent = pkgManager.getLaunchIntentForPackage(appContext.getPackageName()).let { it } ?: return null
      
    intent = Intent(Intent.ACTION_MAIN, null);
    intent.addCategory(Intent.CATEGORY_LAUNCHER);
    intent.setPackage(appContext.getPackageName());
  
    return intent;
  }

  override
  public fun handleIterableURL(uri: Uri, actionContext: IterableActionContext): Boolean {
      IterableLogger.printInfo();

      // val actionContextJson = Serialization.actionContextToJson(actionContext);
      // var eventDataJson = JSONObject();

      // try {
      //     eventDataJson.put("url", uri.toString());
      //     eventDataJson.put("context", actionContextJson);
      //     val eventData = Serialization.convertJsonToMap(eventDataJson);
      //     //sendEvent(EventName.handleUrlCalled.name(), eventData);
      // } catch (JSONException e) {
      //     IterableLogger.e(TAG, e.getLocalizedMessage());
      // }
      return true
  }

  override
  public fun handleIterableCustomAction(action: IterableAction, actionContext: IterableActionContext): Boolean {
      IterableLogger.printInfo();
      // val actionJson = Serialization.actionToJson(action);
      // val actionContextJson = Serialization.actionContextToJson(actionContext);
      // var eventDataJson = JSONObject();
      // try {
      //     eventDataJson.put("action", actionJson);
      //     eventDataJson.put("context", actionContextJson);
      //     val eventData = Serialization.convertJsonToMap(eventDataJson);
      //     //sendEvent(EventName.handleCustomActionCalled.name(), eventData);
      // } catch (JSONException e) {
      //     IterableLogger.e(TAG, "Failed handling custom action");
      // }
      // The Android SDK will not bring the app into focus is this is `true`. It still respects the `openApp` bool flag.
      return false;
  }

  override
  public fun onNewInApp(message: IterableInAppMessage): IterableInAppHandler.InAppResponse {
    IterableLogger.printInfo();

    // JSONObject messageJson = RNIterableInternal.getInAppMessageJson(message);

    // try {
    //     WritableMap eventData = Serialization.convertJsonToMap(messageJson);
    //     jsCallBackLatch = new CountDownLatch(1);
    //     sendEvent(EventName.handleInAppCalled.name(), eventData);
    //     jsCallBackLatch.await(2, TimeUnit.SECONDS);
    //     jsCallBackLatch = null;
    //     return inAppResponse;
    // } catch (InterruptedException | JSONException e) {
    //     IterableLogger.e(TAG, "new in-app module failed");
    //     return InAppResponse.SHOW;
    // }
    return IterableInAppHandler.InAppResponse.SHOW
  }

  override
  public fun onAuthTokenRequested(): String? {
      IterableLogger.printInfo();

      // try {
      //     authHandlerCallbackLatch = new CountDownLatch(1);
      //     sendEvent(EventName.handleAuthCalled.name(), null);
      //     authHandlerCallbackLatch.await(30, TimeUnit.SECONDS);
      //     authHandlerCallbackLatch = null;
      //     return passedAuthToken;
      // } catch (InterruptedException e) {
      //     IterableLogger.e(TAG, "auth handler module failed");
      //     return null;
      // }
      return "blah"
  }

}
