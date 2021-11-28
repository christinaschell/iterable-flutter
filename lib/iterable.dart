import 'dart:async';
import 'dart:convert';
import 'common.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class Iterable {
  static const String pluginName = 'IterableFlutter';
  static const String pluginVersion = '0.0.1';
  static const MethodChannel _channel = MethodChannel('iterable');

  /// Initializes Iterable with an [IterableConfig] object
  ///
  /// [Future<bool>] upon success or failure
  static Future<bool> initialize(String apiKey, IterableConfig config) async {
    var initialized = await _channel.invokeMethod('initialize', {
      'config': {
        'remoteNotificationsEnabled': config.remoteNotificationsEnabled,
        'pushIntegrationName': config.pushIntegrationName,
        'urlHandlerPresent': config.urlHandlerPresent,
        'customActionHandlerPresent': config.customActionHandlerPresent,
        'inAppHandlerPresent': config.inAppHandlerPresent,
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
    return initialized;
  }

  /// Sets email on the user profile
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

  /// Updates the user email
  ///
  /// [Future<String>] upon success or failure
  static Future<String> updateEmail(String email) async {
    return await _channel.invokeMethod('updateEmail', {'email': email});
  }

  /// Sets userId on the user profile
  ///
  /// [Future<String>] user id
  static setUserId(String id) {
    _channel.invokeMethod('setUserId', {'userId': id});
  }

  /// Retrieves the current user id for the user
  static Future<String> getUserId() async {
    return await _channel.invokeMethod('getUserId');
  }

  /// Updates the user fields
  ///
  /// [Future<String>] upon success or failure
  static Future<String> updateUser(
      Map<String, Object> dataFields, bool? mergeNestedObjects) async {
    return await _channel.invokeMethod('updateUser',
        {'dataFields': dataFields, 'mergeNestedObjects': mergeNestedObjects});
  }

  /// Sets the user email and user id at the same time
  ///
  /// [Future<String>] upon success or failure
  static Future<String> setEmailAndUserId(String email, String userId) async {
    return await _channel
        .invokeMethod('setEmailAndUserId', {'email': email, 'userId': userId});
  }

  /// Tracks a custom event
  static trackEvent(String name, Map<String, Object>? dataFields) {
    _channel.invokeMethod(
        'trackEvent', {'eventName': name, 'dataFields': dataFields});
  }

  /// Tracks updates to the cart
  static updateCart(List<IterableCommerceItem> items) {
    var itemsList = items.map((item) => item.toJson()).toList();
    _channel.invokeMethod('updateCart', {'items': itemsList});
  }

  /// Tracks a purchase
  static trackPurchase(double total, List<IterableCommerceItem> items,
      Map<String, Object>? dataFields) {
    var itemsList = items.map((item) => item.toJson()).toList();
    _channel.invokeMethod('trackPurchase',
        {'total': total, 'items': itemsList, 'dataFields': dataFields});
  }

  /// Get the last push payload
  ///
  /// [Future<String>] JSON string: the most recent push payload
  static Future<String> getLastPushPayload() async {
    return await _channel.invokeMethod('getLastPushPayload');
  }
}
