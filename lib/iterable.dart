import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart' as URLLaucher;
import 'common.dart';
import 'events/event_emitter.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class Iterable {
  static const String pluginName = 'IterableFlutter';
  static const String pluginVersion = '0.0.1';
  static const MethodChannel _channel = MethodChannel('iterable');
  static EventEmitter emitter = EventEmitter();
  static var inAppManager = IterableInAppManager();
  static final Map<String, Function> _listeners = {};
  static Timer? timer;

  /// Initializes Iterable with an [apiKey] and an Iterable [config] object
  ///
  /// [Future<bool>] upon success or failure
  static Future<bool> initialize(String apiKey, IterableConfig config) async {
    bool inAppHandlerPresent = config.inAppDelegate != null;
    bool urlHandlerPresent = config.urlHandler != null;
    debugPrint("🔥config.urlDelegate: ${config.urlHandler}");
    debugPrint("🔥urlDelegatePresent: $urlHandlerPresent");
    var initialized = await _channel.invokeMethod('initialize', {
      'config': {
        'remoteNotificationsEnabled': config.remoteNotificationsEnabled,
        'pushIntegrationName': config.pushIntegrationName,
        'urlHandlerPresent': urlHandlerPresent,
        'customActionHandlerPresent': config.customActionHandlerPresent,
        'inAppHandlerPresent': inAppHandlerPresent,
        'authHandlerPresent': config.authHandlerPresent,
        'autoPushRegistration': config.autoPushRegistration,
        'inAppDisplayInterval': config.inAppDisplayInterval,
        'expiringAuthTokenRefreshPeriod': config.expiringAuthTokenRefreshPeriod,
        'logLevel': config.logLevel
      },
      'version': pluginVersion,
      'pluginName': pluginName,
      'apiKey': apiKey
    });
    if (inAppHandlerPresent) {
      setInAppHandler(config.inAppDelegate!);
    }
    if (urlHandlerPresent) {
      setUrlHandler(config.urlHandler!);
    }
    return initialized;
  }

  /// Sets [email] on the user profile
  static setEmail(String email) {
    developer.log("setEmail in iterable.dart: " + email);
    _channel.invokeMethod('setEmail', {'email': email});
  }

  /// Retrieves the current email for the user
  ///
  /// [Future<String>] user email
  static Future<String> getEmail() async {
    return await _channel.invokeMethod('getEmail');
  }

  /// Updates the user [email]
  ///
  /// [Future<String>] upon success or failure
  static Future<String> updateEmail(String email) async {
    return await _channel.invokeMethod('updateEmail', {'email': email});
  }

  /// Sets user [id] on the user profile
  static setUserId(String id) {
    _channel.invokeMethod('setUserId', {'userId': id});
  }

  /// Retrieves the current user id for the user
  ///
  /// [Future<String>] user id
  static Future<String> getUserId() async {
    return await _channel.invokeMethod('getUserId');
  }

  /// Updates the user [dataFields]
  ///
  /// [Future<String>] upon success or failure
  static Future<String> updateUser(
      Map<String, Object> dataFields, bool? mergeNestedObjects) async {
    return await _channel.invokeMethod('updateUser',
        {'dataFields': dataFields, 'mergeNestedObjects': mergeNestedObjects});
  }

  /// Sets the user [email] and [userId] at the same time
  ///
  /// [Future<String>] upon success or failure
  static Future<String> setEmailAndUserId(String email, String userId) async {
    return await _channel
        .invokeMethod('setEmailAndUserId', {'email': email, 'userId': userId});
  }

  /// Retrieves attribution info (campaignId, messageId etc.) for last push open or app link click from an email.
  ///
  /// [Future<IterableAttributionInfo>]
  static Future<IterableAttributionInfo?> getAttributionInfo() async {
    var attrInfo = await _channel.invokeMethod('getAttributionInfo');
    if (attrInfo != null) {
      return IterableAttributionInfo(attrInfo["campaignId"] as int,
          attrInfo["templateId"] as int, attrInfo["messageId"] as String);
    } else {
      return null;
    }
  }

  /// Sets [attributionInfo] (campaignId, messageId etc.) for last push open or app link click from an email.
  static setAttributionInfo(IterableAttributionInfo attributionInfo) {
    _channel.invokeMethod(
        'setAttributionInfo', {'attributionInfo': attributionInfo.toJson()});
  }

  /// Tracks a custom event with [name] and optional [dataFields]
  static trackEvent(String name, Map<String, Object>? dataFields) {
    _channel.invokeMethod(
        'trackEvent', {'eventName': name, 'dataFields': dataFields});
  }

  /// Tracks updates to the cart [items]
  static updateCart(List<IterableCommerceItem> items) {
    var itemsList = items.map((item) => item.toJson()).toList();
    _channel.invokeMethod('updateCart', {'items': itemsList});
  }

  /// Tracks a purchase with order [total] cart [items] and optional [dataFields]
  static trackPurchase(double total, List<IterableCommerceItem> items,
      Map<String, Object>? dataFields) {
    var itemsList = items.map((item) => item.toJson()).toList();
    _channel.invokeMethod('trackPurchase',
        {'total': total, 'items': itemsList, 'dataFields': dataFields});
  }

  /// Disables the device for a current user
  static disableDeviceForCurrentUser() {
    _channel.invokeMethod('disableDeviceForCurrentUser');
  }

  /// Tracks a push open event manually
  static trackPushOpenWithCampaignId(
      int campaignId,
      int templateId,
      String messageId,
      bool appAlreadyRunning,
      Map<String, Object>? dataFields) {
    _channel.invokeMethod('trackPushOpen', {
      'campaignId': campaignId,
      'templateId': templateId,
      'messageId': messageId,
      'appAlreadyRunning': appAlreadyRunning,
      'dataFields': dataFields
    });
  }

  /// Get the last push payload
  ///
  /// [Future<dynamic>] the most recent push payload
  static Future<dynamic> getLastPushPayload() async {
    return await _channel.invokeMethod('getLastPushPayload');
  }

  /// Updates subscription preferences for the user
  /// from a list of [emailListIds] or [unsubscribedChannelIds]
  /// or [unsubscribedMessageTypeIds] or [subscribedMessageTypeIds]
  /// can also optionally include [campaignId] and/or [templateId]
  static updateSubscriptions(
      {List<int>? emailListIds,
      List<int>? unsubscribedChannelIds,
      List<int>? unsubscribedMessageTypeIds,
      List<int>? subscribedMessageTypeIds,
      int? campaignId,
      int? templateId}) {
    _channel.invokeMethod('updateSubscriptions', {
      'emailListIds': emailListIds,
      'unsubscribedChannelIds': unsubscribedChannelIds,
      'unsubscribedMessageTypeIds': unsubscribedMessageTypeIds,
      'subscribedMessageTypeIds': subscribedMessageTypeIds,
      'campaignId': campaignId,
      'templateId': templateId
    });
  }

  /// Tracks an in-app open event manually
  static trackInAppOpen(
      IterableInAppMessage message, IterableInAppLocation location) {
    // toJson for these
    _channel.invokeMethod('trackInAppOpen',
        {'message': message.messageId, 'location': location.toInt()});
  }

  /// Tracks an in-app click event manually
  static trackInAppClick(IterableInAppMessage message,
      IterableInAppLocation location, String clickedUrl) {
    _channel.invokeMethod('trackInAppClick', {
      'message': message.toJson(),
      'location': location.toInt(),
      'clickedUrl': clickedUrl
    });
  }

  /// Tracks an in-app close event manually
  static trackInAppClose(
      IterableInAppMessage message,
      IterableInAppLocation location,
      IterableInAppCloseSource source,
      String? clickedUrl) {
    _channel.invokeMethod('trackInAppClose', {
      'message': message.toJson(),
      'location': location.toInt(),
      'source': source.toInt(),
      'clickedUrl': clickedUrl
    });
  }

  /// Consumes an in-app message from the queue
  static inAppConsume(IterableInAppMessage message,
      IterableInAppLocation location, IterableInAppDeleteSource source) {
    _channel.invokeMethod('inAppConsume', {
      'message': message.toJson(),
      'location': location.toInt(),
      'source': source.toInt(),
    });
  }

  /// Wakes the app in Android
  static wakeApp() {
    if (Platform.isAndroid) {
      _channel.invokeMethod('wakeApp');
    }
  }

  static Future<bool> handleAppLink(String link) async {
    return Iterable.handleAppLink(link);
  }

// not sure if needed
  static setInAppShowResponse(IterableInAppShowResponse response) {
    _channel.invokeMethod(
        'setInAppShowResponse', {'showResponse': response.toInt()});
  }

  /// Sets the callback for the [InAppHanlder]
  static setInAppHandler(InAppHandlerCallback callback) {
    _listeners[EventListenerNames.inAppHandler] = callback;
    _handleListener(EventListenerNames.inAppHandler);
  }

  static setUrlHandler(UrlHandlerCallback callback) {
    _listeners[EventListenerNames.urlHandler] = callback;
    _handleListener(EventListenerNames.urlHandler);
  }

  static callUrlHandler(
      String url, IterableActionContext context, Function callback) {
    bool handledResult = callback(url, context);
    if (handledResult == false) {
      URLLaucher.canLaunch(url).then((canOpen) => {
            if (canOpen)
              {URLLaucher.launch(url)}
            else
              {debugPrint("Could not open Url.")}
          });
    }
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method.toString() == 'callListener') {
      emitter.emit(
          call.arguments[EventListenerNames.name], null, call.arguments);
    }
  }

  static _handleListener(String eventName) {
    _channel.setMethodCallHandler(_methodCallHandler);
    emitter.on(eventName, {}, (ev, context) {
      switch (eventName) {
        case EventListenerNames.inAppHandler:
          var encodedData = jsonEncode(ev.eventData);
          var eventDataMap = jsonDecode(encodedData) as Map;
          var message = IterableInAppMessage.from(jsonEncode(eventDataMap));
          Function callback =
              _listeners[EventListenerNames.inAppHandler] as Function;
          var response = callback(message);
          setInAppShowResponse(response);
          break;
        case EventListenerNames.urlHandler:
          dynamic encodedData = jsonEncode(ev.eventData);
          Map eventDataMap = jsonDecode(encodedData) as Map;
          String url = eventDataMap["url"];
          IterableActionContext context =
              IterableActionContext.from(eventDataMap["context"]);
          Function callback =
              _listeners[EventListenerNames.urlHandler] as Function;
          Iterable.wakeApp();
          if (Platform.isAndroid) {
            // Give enough time for Activity to wake up.
            timer = Timer(const Duration(seconds: 1),
                () => callUrlHandler(url, context, callback));
          } else {
            callUrlHandler(url, context, callback);
          }
          break;
        // case EventListenerNames.consentExpired:
        //   Function callback = _listeners[EventListenerNames.consentExpired] =
        //       _listeners[EventListenerNames.consentExpired] as Function;
        //   callback();
        //   break;
        // case EventListenerNames.visitor:
        //   var encodedData = json.encode(ev.eventData);
        //   var eventDataMap = json.decode(encodedData);
        //   eventDataMap as Map;
        //   eventDataMap.remove(EventListenerNames.name);
        //   Function callback = _listeners[EventListenerNames.visitor] =
        //       _listeners[EventListenerNames.visitor] as Function;
        //   callback(eventDataMap);
        //   break;
        default:
          break;
      }
    });
  }
}
