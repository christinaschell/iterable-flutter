package com.schelly.iterable

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.iterable.iterableapi.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.collections.*


/** IterablePlugin */
class IterablePlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, IterableUrlHandler, IterableCustomActionHandler, IterableInAppHandler, IterableAuthHandler {

  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity

  private var inAppResponse = IterableInAppHandler.InAppResponse.SHOW
  private var inAppShowResponseLatch: CountDownLatch? = null

  private var passedAuthToken: String? = null
  private var authHandlerCallbackLatch: CountDownLatch? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getBinaryMessenger(), "iterable")
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.applicationContext
  }

  override
  fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override
  fun onMethodCall(call: MethodCall, result: Result) {
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
      "getInAppMessages" -> getInAppMessages(result)
      "disableDeviceForCurrentUser" -> disableDeviceForCurrentUser()
      "trackPushOpen" -> trackPushOpen(call)
      "trackInAppOpen" -> trackInAppOpen(call)
      "trackInAppClick" -> trackInAppClick(call)
      "trackInAppClose" -> trackInAppClose(call)
      "inAppConsume" -> inAppConsume(call)
      "showMessage" -> showMessage(call, result)
      "setReadForMessage" -> setReadForMessage(call)
      "removeMessage" -> removeMessage(call)
      "getHtmlContentForMessage" -> getHtmlInAppContent(call, result)
      "setInAppShowResponse" -> setInAppShowResponse(call)
      "wakeApp" -> wakeApp()
      "setAutoDisplayPaused" -> setAutoDisplayPaused(call)
      "handleAppLink" -> handleAppLink(call, result)
      "setAuthToken" -> setAuthToken(call)
      else -> result.onMain().notImplemented()
  }
  }

  private fun initialize(call: MethodCall, result: Result) {
    val args = call.arguments as Map<*, *>
    val configMap = args[CONFIG] as Map<*, *>
    val apiKey = args[API_KEY] as String
    val version = args[VERSION] as String

    toIterableConfig(configMap).let { config ->

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

      context.let { context ->
        Handler(Looper.getMainLooper()).post {
          IterableApi.initialize(context, apiKey, config.build())
          Log.d(BuildConfig.TAG, "Instance Initialized")
          IterableApi.getInstance().setDeviceAttribute(SDK_VERSION, version)
          result.onMain().success(true)
        }
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
    val email = call.argument<String>("email") ?: return 
    
    IterableApi.getInstance().updateEmail(email, {
      result.onMain().success("updateEmail to $email was successful.")
      }, { reason, _ ->
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
    val dataFields = call.argument<Map<*, *>>("dataFields") ?: return
    val mergeNestedObjects = call.argument<Boolean>("mergeNestedObjects") ?: true
    
    IterableApi.getInstance().updateUser(JSONObject(dataFields), mergeNestedObjects)
    result.onMain().success("updateUser successful with dataFields: ${dataFields.toString()}")
  }

  private fun setEmailAndUserId(call: MethodCall, result: Result) {
    val email = call.argument<String>("email") ?: return
    val userId = call.argument<String>("userId") ?: return 
    
    IterableApi.getInstance().updateEmail(email, {
      IterableApi.getInstance().updateUser(JSONObject().put("userId", userId), true)
        IterableApi.getInstance().setUserId(userId)
        result.onMain().success("setEmailAndUserId successful")
    }, { reason, _ ->
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
    val attrInfo = call.argument<Map<*,*>>("attributionInfo") ?: return
    val attrInfoJSON = JSONObject(attrInfo)
    val attributionInfo: IterableAttributionInfo = IterableAttributionInfo.fromJSONObject(attrInfoJSON) ?: return

    FlutterInternalIterable.setAttributionInfo(attributionInfo)
  }

  private fun trackEvent(call: MethodCall) {
    val eventName = call.argument<String>("eventName") ?: return
    val dataFields = call.argument<Map<*, *>>("dataFields")

    IterableApi.getInstance().track(eventName, JSONObject(dataFields))
  }
  
  private fun updateCart(call: MethodCall) {
    val items = call.argument<List<Map<*,*>>>("items") ?: return
    val commerceItems = items.mapNotNull { item -> commerceItemFromMap(item) }

    IterableApi.getInstance().updateCart(commerceItems)
  }

  private fun trackPurchase(call: MethodCall) {
    val total = call.argument<Double>("total") ?: return
    val items = call.argument<List<Map<*,*>>>("items") ?: return
    val dataFields = call.argument<Map<*, *>>("dataFields")

    val commerceItems = items.mapNotNull { item -> commerceItemFromMap(item) }

    IterableApi.getInstance().trackPurchase(total, commerceItems, JSONObject(dataFields))
  }

  private fun getLastPushPayload(result: Result) {
    val payloadData = IterableApi.getInstance().payloadData
    val payloadMap = HashMap<String, Any?>()

    payloadData?.let { data -> 
      data.keySet()?.forEach { key ->
        payloadMap[key] = data.get(key)
      }
    }

    result.onMain().success(payloadMap)
  }

  private fun disableDeviceForCurrentUser() {
    IterableApi.getInstance().disablePush()
  }

  private fun trackPushOpen(call: MethodCall) {
    val campaignId = call.argument<Int>("campaignId") ?: return
    val templateId = call.argument<Int>("templateId") ?: return
    val messageId = call.argument<String>("messageId") ?: return
    val dataFields = call.argument<Map<*, *>>("dataFields")

    FlutterInternalIterable.trackPushOpenWithCampaignId(campaignId, templateId, messageId, JSONObject(dataFields))
  }

  private fun trackInAppOpen(call: MethodCall) {
    val messageId = call.argument<String>("messageId") ?: return
    IterableApi.getInstance().trackInAppOpen(messageId)
  }

  private fun trackInAppClick(call: MethodCall) {
    val messageId = call.argument<String>("messageId") ?: return
    val clickedUrl = call.argument<String>("clickedUrl") ?: return
    IterableApi.getInstance().trackInAppClick(messageId, clickedUrl)
  }

  private fun trackInAppClose(call: MethodCall) {
    val messageId = call.argument<String>("messageId") ?: return
    val clickedUrl = call.argument<String>("clickedUrl") ?: return
    val source = call.argument<Int>("source") ?: return
    val location = call.argument<Int>("location") ?: return

    val closeAction = getIterableInAppCloseSourceFromInteger(source) ?: IterableInAppCloseAction.OTHER
    val inAppLocation = getIterableInAppLocationFromInteger(location) ?: IterableInAppLocation.IN_APP

    FlutterInternalIterable.trackInAppClose(messageId, clickedUrl, closeAction, inAppLocation)
  }

  private fun inAppConsume(call: MethodCall) {
    val messageId = call.argument<String>("messageId") ?: return
    val message = FlutterInternalIterable.getMessageById(messageId) ?: return
    val source = call.argument<Int>("source")
    val location = call.argument<Int>("location")

    val deleteActionType = getIterableDeleteActionTypeFromInteger(source)
    val inAppLocation = getIterableInAppLocationFromInteger(location)

    IterableApi.getInstance().inAppConsume(message, deleteActionType, inAppLocation)
  }

  private fun getInAppMessages(result: Result) {
    val inAppMessages = IterableApi.getInstance().getInAppManager().getMessages()
    val inAppMessagesMapArray = inAppMessages.map { message -> 
      inAppMessageToMap(message)
    }
    result.onMain().success(inAppMessagesMapArray)
  }

  private fun showMessage(call: MethodCall, result: Result) {
    val messageId = call.argument<String>("messageId") ?: return
    val consume = call.argument<Boolean>("consume") ?: true
    val message = FlutterInternalIterable.getMessageById(messageId) ?: return

    IterableApi.getInstance().inAppManager.showMessage(
      message, consume
    ) { url -> result.onMain().success(url.toString()) }
  }

  private fun setReadForMessage(call: MethodCall) {
    val messageId = call.argument<String>("messageId") ?: return
    val read = call.argument<Boolean>("read") ?: true
    val message = FlutterInternalIterable.getMessageById(messageId) ?: return

    IterableApi.getInstance().inAppManager.setRead(message, read);
  }

  private fun removeMessage(call: MethodCall) {
    val messageId = call.argument<String>("messageId") ?: return
    val source = call.argument<Int>("source") ?: return
    val location = call.argument<Int>("location") ?: return
    val message = FlutterInternalIterable.getMessageById(messageId) ?: return

    val deleteActionType = getIterableDeleteActionTypeFromInteger(source) ?: IterableInAppDeleteActionType.OTHER
    val inAppLocation = getIterableInAppLocationFromInteger(location) ?: IterableInAppLocation.IN_APP
    
    IterableApi.getInstance().inAppManager.removeMessage(message, deleteActionType, inAppLocation);
  }

  private fun getHtmlInAppContent(call: MethodCall, result: Result) {
    val messageId = call.argument<String>("messageId") ?: return
    val message = FlutterInternalIterable.getMessageById(messageId) ?: return
    val encodedHtmlContent = htmlContentToJsonString(message.content)
    result.onMain().success(encodedHtmlContent)
  }

  private fun setAutoDisplayPaused(call: MethodCall) {
    val paused = call.argument<Boolean>("paused") ?: false
    Handler(Looper.getMainLooper()).post {
      IterableApi.getInstance().inAppManager.setAutoDisplayPaused(paused);
    }
  }

  private fun setInAppShowResponse(call: MethodCall) {
    val showResponse = call.argument<Int>("showResponse") ?: return
    inAppResponse = getInAppResponse(showResponse) ?: IterableInAppHandler.InAppResponse.SHOW
    inAppShowResponseLatch?.countDown()
  }

  private fun handleAppLink(call: MethodCall, result: Result) {
    val uri = call.argument<String>("uri") ?: return
    result.onMain().success(IterableApi.getInstance().handleAppLink(uri))
  }

  private fun setAuthToken(call: MethodCall) {
    val token = call.argument<String>("token") ?: return
    passedAuthToken = token
    authHandlerCallbackLatch?.countDown()
  }

  private fun wakeApp() {
    val launcherIntent = getMainActivityIntent() ?: return 
    val pkgManager = context.packageManager ?: return
    launcherIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
    
    if (launcherIntent.resolveActivity(pkgManager) != null) {
        context.startActivity(launcherIntent);
    }
  }

  private fun getMainActivityIntent(): Intent? {

    val intent = Intent(Intent.ACTION_MAIN, null)
    intent.addCategory(Intent.CATEGORY_LAUNCHER)
    intent.setPackage(context.packageName)
  
    return intent
  }

  override
  fun handleIterableURL(uri: Uri, actionContext: IterableActionContext): Boolean {
    IterableLogger.printInfo();

    val eventData = mutableMapOf("url" to uri.toString(), "context" to actionContextToMap(actionContext))
    eventData[EMITTER_NAME] = URL_DELEGATE
    invokeOnMain(channel, "callListener", eventData)

    return true
  }

  override
  fun handleIterableCustomAction(action: IterableAction, actionContext: IterableActionContext): Boolean {
    IterableLogger.printInfo();

    val eventData = customActionToMap(action, actionContext).toMutableMap()
    eventData[EMITTER_NAME] = CUSTOM_ACTION_DELEGATE
    invokeOnMain(channel, "callListener", eventData)

    // The Android SDK will not bring the app into focus is this is `true`. It still respects the `openApp` bool flag.
    return false;
  }

  override
  fun onNewInApp(message: IterableInAppMessage): IterableInAppHandler.InAppResponse {
    IterableLogger.printInfo();

    val eventData = inAppMessageToMap(message).toMutableMap()

    eventData[EMITTER_NAME] = INAPP_DELEGATE
    invokeOnMain(channel, "callListener", eventData)

    inAppShowResponseLatch = CountDownLatch(1)
    inAppShowResponseLatch?.await(2, TimeUnit.SECONDS)
    inAppShowResponseLatch = null
    return inAppResponse

  }

  override
  fun onAuthTokenRequested(): String? {
    IterableLogger.printInfo();

    authHandlerCallbackLatch = CountDownLatch(1)
    invokeOnMain(channel, "callListener", mapOf(EMITTER_NAME to AUTH_DELEGATE))

    authHandlerCallbackLatch?.await(30, TimeUnit.SECONDS)
    authHandlerCallbackLatch = null
    return passedAuthToken

  }

  override
  fun onDetachedFromActivity() { }

  override
  fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    IterableApi.setContext(activity)
  }

  override
  fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    IterableApi.setContext(activity)
  }

  override fun onDetachedFromActivityForConfigChanges() { }

  companion object {
    fun invokeOnMain(methodChannel: MethodChannel, listener: String, data: Any?) {
      Handler(Looper.getMainLooper()).post {
        methodChannel.invokeMethod(listener, data)
      }
    }
  }

}
