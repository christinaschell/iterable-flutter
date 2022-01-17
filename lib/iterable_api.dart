import 'dart:async';
import 'package:iterable/inapp/inapp_manager.dart';
import 'inapp/inapp_common.dart';
import 'common.dart';
import 'package:flutter/services.dart';
import 'events/event_handler.dart';

class IterableAPI {
  static const String pluginVersion = '0.0.1';
  static const MethodChannel _channel = MethodChannel('iterable');
  static var inAppManager = IterableInAppManager();
  static var events = IterableEventHandler(channel: _channel);

  /// Initializes Iterable with an [apiKey] and an Iterable [config] object
  ///
  /// [Future<bool>] upon success or failure
  static Future<bool> initialize(String apiKey, IterableConfig config) async {
    bool inAppHandlerPresent = config.inAppHandler != null;
    bool urlHandlerPresent = config.urlHandler != null;
    bool customActionHandlerPresent = config.customActionHandler != null;
    bool authHandlerPresent = config.authHandler != null;

    var initialized = await _channel.invokeMethod('initialize', {
      'config': {
        'pushIntegrationName': config.pushIntegrationName,
        'urlHandlerPresent': urlHandlerPresent,
        'customActionHandlerPresent': customActionHandlerPresent,
        'inAppHandlerPresent': inAppHandlerPresent,
        'authHandlerPresent': authHandlerPresent,
        'autoPushRegistration': config.autoPushRegistration,
        'inAppDisplayInterval': config.inAppDisplayInterval,
        'expiringAuthTokenRefreshPeriod': config.expiringAuthTokenRefreshPeriod,
        'logLevel': config.logLevel
      },
      'version': pluginVersion,
      'apiKey': apiKey
    });
    if (inAppHandlerPresent) {
      events.setEventHandler(
          EventListenerNames.inAppHandler, config.inAppHandler!);
    }
    if (urlHandlerPresent) {
      events.setEventHandler(EventListenerNames.urlHandler, config.urlHandler!);
    }
    if (customActionHandlerPresent) {
      events.setEventHandler(
          EventListenerNames.customActionHandler, config.customActionHandler!);
    }
    if (authHandlerPresent) {
      events.setEventHandler(
          EventListenerNames.authHandler, config.authHandler!);
    }
    return initialized;
  }

  /// Sets [email] on the user profile
  static setEmail(String? email) {
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
  static setUserId(String? id) {
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

  /// Retrieves the current attribution information (based on a recent deep link click)
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

  /// Manually sets the current attribution information so that it can later be used when tracking events
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

  /// Tracks an in-app [message] open event manually
  static trackInAppOpen(
      IterableInAppMessage message, IterableInAppLocation location) {
    _channel.invokeMethod('trackInAppOpen',
        {'messageId': message.messageId, 'location': location.toInt()});
  }

  /// Tracks an in-app [message] click event manually
  static trackInAppClick(IterableInAppMessage message,
      IterableInAppLocation location, String clickedUrl) {
    _channel.invokeMethod('trackInAppClick', {
      'messageId': message.messageId,
      'location': location.toInt(),
      'clickedUrl': clickedUrl
    });
  }

  /// Tracks an in-app [message] close event manually
  static trackInAppClose(
      IterableInAppMessage message,
      IterableInAppLocation location,
      IterableInAppCloseSource source,
      String? clickedUrl) {
    _channel.invokeMethod('trackInAppClose', {
      'messageId': message.messageId,
      'location': location.toInt(),
      'source': source.toInt(),
      'clickedUrl': clickedUrl
    });
  }

  /// Consumes an in-app [message] from the queue
  static inAppConsume(IterableInAppMessage message,
      IterableInAppLocation location, IterableInAppDeleteSource source) {
    _channel.invokeMethod('inAppConsume', {
      'messageId': message.messageId,
      'location': location.toInt(),
      'source': source.toInt(),
    });
  }
}
