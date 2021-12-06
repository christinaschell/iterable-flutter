import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore_for_file: prefer_initializing_formals

class IterableConfig {
  bool? remoteNotificationsEnabled;
  String? pushIntegrationName;
  String? urlHandlerPresent;
  String? customActionHandlerPresent;
  String? inAppHandlerPresent;
  String? authHandlerPresent;
  bool? autoPushRegistration; // default true
  double? inAppDisplayInterval;
  double? expiringAuthTokenRefreshPeriod;
  int? logLevel;
  // Function? urlHanler; // stub urlHandler

  IterableConfig(
      {bool? remoteNotificationsEnabled,
      String? pushIntegrationName,
      String? urlHandlerPresent,
      String? customActionHandlerPresent,
      String? inAppHandlerPresent,
      String? authHandlerPresent,
      bool? autoPushRegistration,
      double? inAppDisplayInterval,
      double? expiringAuthTokenRefreshPeriod,
      IterableLogLevel? logLevel}) {
    this.remoteNotificationsEnabled = remoteNotificationsEnabled ?? true;
    this.pushIntegrationName = pushIntegrationName;
    this.urlHandlerPresent = urlHandlerPresent;
    this.customActionHandlerPresent = customActionHandlerPresent;
    this.inAppHandlerPresent = inAppHandlerPresent;
    this.authHandlerPresent = authHandlerPresent;
    this.autoPushRegistration = autoPushRegistration ?? true;
    this.inAppDisplayInterval = inAppDisplayInterval ?? 30.0;
    this.expiringAuthTokenRefreshPeriod =
        expiringAuthTokenRefreshPeriod ?? 60.0;
    this.logLevel = logLevel?.toInt() ?? IterableLogLevel.info.toInt();
  }
}

class IterableActionSource {
  final int _value;

  const IterableActionSource._(this._value);

  int toInt() {
    return _value;
  }

  static const IterableActionSource push = IterableActionSource._(0);
  static const IterableActionSource appLink = IterableActionSource._(1);
  static const IterableActionSource inApp = IterableActionSource._(2);
}

class IterableAction {
  late String type;
  String? data;
  String? userInput;

  IterableAction(String type, {String? data, String? userInput}) {
    this.type = type;
    this.data = data;
    this.userInput = userInput;
  }

  // Note: might not need
  Map<String, dynamic> toJson() =>
      {'type': type, 'data': data, 'userInput': userInput};
}

class IterableActionContext {
  late IterableAction action;
  late IterableActionSource source;

  IterableActionContext(IterableAction action, IterableActionSource source) {
    this.action = action;
    this.source = source;
  }

  // Note: might not need
  Map<String, dynamic> toJson() => {'action': action, 'source': source};
}

// abstract class IterableLogLevel {

//   static int debug = 1;
//   static int info = 2;
//   static int error = 3;

// }

class IterableLogLevel {
  final int _value;

  const IterableLogLevel._(this._value);

  int toInt() {
    return _value;
  }

  static const IterableLogLevel debug = IterableLogLevel._(1);
  static const IterableLogLevel info = IterableLogLevel._(2);
  static const IterableLogLevel error = IterableLogLevel._(3);
}

class IterableCommerceItem {
  late String id;
  late String name;
  late double price;
  late int quantity;
  String? sku;
  String? description;
  String? url;
  String? imageUrl;
  List<String>? categories;
  Map<String, Object>? dataFields;

  IterableCommerceItem(String id, String name, double price, int quantity,
      {String? sku,
      String? description,
      String? url,
      String? imageUrl,
      List<String>? categories,
      Map<String, Object>? dataFields}) {
    this.id = id;
    this.name = name;
    this.price = price;
    this.quantity = quantity;
    this.sku = sku;
    this.description = description;
    this.url = url;
    this.imageUrl = imageUrl;
    this.categories = categories;
    this.dataFields = dataFields;
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'sku': sku,
        'description': description,
        'url': url,
        'imageUrl': imageUrl,
        'categories': categories,
        'dataFields': dataFields
      };
}

/// In App Classes

enum IterableInAppShowResponse { show, skip }

enum IterableInAppTriggerType { immediate, event, never }

class IterableInAppTrigger {
  late IterableInAppTriggerType type;

  IterableInAppTrigger({required this.type});

  IterableInAppTrigger.fromIndex(int index) {
    type = IterableInAppTriggerType.values[index];
  }

  static IterableInAppTrigger from(String json) {
    final dictionary = jsonDecode(json) as Map<String, dynamic>;
    int type = dictionary["type"] ?? 0;
    return IterableInAppTrigger.fromIndex(type);
  }
}

enum IterableInAppContentType { html, alert, banner }

enum IterableInAppLocation { inApp, inbox }

abstract class IterableInAppCloseSource {
  static int back = 0;
  static int link = 1;
  static int unknown = 100;
}

class IterableInAppDeleteSource {
  final int _value;

  const IterableInAppDeleteSource._(this._value);

  int toInt() {
    return _value;
  }

  static const IterableInAppDeleteSource inboxSwipe =
      IterableInAppDeleteSource._(0);
  static const IterableInAppDeleteSource deleteButton =
      IterableInAppDeleteSource._(1);
  static const IterableInAppDeleteSource unknown =
      IterableInAppDeleteSource._(100);
}

class IterableInboxMetadata {
  String? title;
  String? subtitle;
  String? icon;

  IterableInboxMetadata(String? title, String? subtitle, String? icon) {
    this.title = title;
    this.subtitle = subtitle;
    this.icon = icon;
  }

  static IterableInboxMetadata from(Map<String, Object> dictionary) {
    return IterableInboxMetadata(dictionary["title"] as String,
        dictionary["subtitle"] as String, dictionary["icon"] as String);
  }
}

class IterableEdgeInset {
  late int percentage;

  IterableEdgeInset(int percentage) {
    this.percentage = percentage;
  }

  static IterableEdgeInset from(Map<String, Object> dictionary) {
    return IterableEdgeInset(dictionary["percentage"] as int);
  }
}

class IterableInAppBackgroundColor {
  late double alpha;
  late String hex;

  IterableInAppBackgroundColor(double alpha, String hex) {
    this.alpha = alpha;
    this.hex = hex;
  }

  static IterableInAppBackgroundColor from(Map<String, Object> dictionary) {
    return IterableInAppBackgroundColor(
        dictionary["alpha"] as double, dictionary["hex"] as String);
  }
}

class IterableInAppDisplaySettings {
  late IterableEdgeInset top;
  late IterableEdgeInset left;
  late IterableEdgeInset bottom;
  late IterableEdgeInset right;
  IterableInAppBackgroundColor? bgColor;
  bool? shouldAnimate;

  IterableInAppDisplaySettings(
      IterableEdgeInset top,
      IterableEdgeInset left,
      IterableEdgeInset bottom,
      IterableEdgeInset right,
      IterableInAppBackgroundColor? bgColor,
      bool? shouldAnimate) {
    this.top = top;
    this.top = left;
    this.top = bottom;
    this.top = right;
    this.bgColor = bgColor;
    this.shouldAnimate = shouldAnimate;
  }

  static IterableInAppDisplaySettings from(Map<String, Object> dictionary) {
    var bg = dictionary["bgColor"] != null
        ? IterableInAppBackgroundColor.from(
            dictionary["bgColor"] as Map<String, Object>)
        : null;
    var animate = dictionary["shouldAnimate"] != null
        ? dictionary["shouldAnimate"] as bool
        : null;
    return IterableInAppDisplaySettings(
        IterableEdgeInset.from(dictionary["top"] as Map<String, int>),
        IterableEdgeInset.from(dictionary["left"] as Map<String, int>),
        IterableEdgeInset.from(dictionary["bottom"] as Map<String, int>),
        IterableEdgeInset.from(dictionary["right"] as Map<String, int>),
        bg,
        animate);
  }
}

class IterableWebInAppDisplaySettings {
  late String position;

  IterableWebInAppDisplaySettings(String position) {
    this.position = position;
  }

  static IterableWebInAppDisplaySettings from(Map<String, Object> dictionary) {
    return IterableWebInAppDisplaySettings(dictionary["position"] as String);
  }
}

class IterableInAppContent {
  late String html;
  late Map<String, Object> payload;
  late IterableInAppDisplaySettings inAppDisplaySettings;
  late IterableWebInAppDisplaySettings? webInAppDisplaySettings;

  IterableInAppContent(
      String html,
      Map<String, Object> payload,
      IterableInAppDisplaySettings inAppDisplaySettings,
      IterableWebInAppDisplaySettings webInAppDisplaySettings) {
    this.html = html;
    this.payload = payload;
    this.inAppDisplaySettings = inAppDisplaySettings;
    this.webInAppDisplaySettings = webInAppDisplaySettings;
  }

  static IterableInAppContent from(Map<String, Object> dictionary) {
    var inAppDisplay = IterableInAppDisplaySettings.from(
        dictionary["inAppDisplaySettings"] as Map<String, Object>);
    var webInAppDisplay = IterableWebInAppDisplaySettings.from(
        dictionary["webInAppDisplaySettings"] as Map<String, Object>);
    return IterableInAppContent(
        dictionary["html"] as String,
        dictionary["payload"] as Map<String, Object>,
        inAppDisplay,
        webInAppDisplay);
  }
}

// In App Message
class IterableInAppMessage {
  late String messageId;
  late int campaignId;
  //late IterableInAppContent content;
  late IterableInAppTrigger trigger;
  late bool saveToInbox;
  late bool read;
  late double priorityLevel;
  DateTime? createdAt;
  DateTime? expiresAt;
  IterableInboxMetadata? inboxMetadata;
  Map<String, Object>? customPayload;

  IterableInAppMessage(
      String messageId,
      int campaignId,
      //IterableInAppContent content,
      IterableInAppTrigger trigger,
      bool saveToInbox,
      bool read,
      double priorityLevel,
      {DateTime? createdAt,
      DateTime? expiresAt,
      IterableInboxMetadata? inboxMetadata,
      Map<String, Object>? customPayload}) {
    this.messageId = messageId;
    this.campaignId = campaignId;
    //this.content = content;
    this.trigger = trigger;
    this.saveToInbox = saveToInbox;
    this.read = read;
    this.priorityLevel = priorityLevel;
    this.createdAt = createdAt;
    this.expiresAt = expiresAt;
    this.inboxMetadata = inboxMetadata;
    this.customPayload = customPayload;
  }

  bool isSilentInbox() =>
      saveToInbox && trigger.type == IterableInAppTriggerType.never;

  /// Debug purposes only
  dynamic toJson() {
    return {
      'messageId': messageId,
      'campaignId': campaignId,
      //'content': jsonEncode(content),
      'trigger': {'type': trigger.type.index},
      'saveToInbox': saveToInbox,
      'customPayload': customPayload,
      'read': read,
      'priorityLevel': priorityLevel,
      'createdAt': createdAt?.toIso8601String() ?? 0,
      'expiresAt': expiresAt?.toIso8601String() ?? 0,
      'inboxMetadata': {
        'title': inboxMetadata?.title ?? "",
        'subtitle': inboxMetadata?.subtitle ?? "",
        'icon': inboxMetadata?.icon ?? "",
      }
    };
  }

  static IterableInAppMessage from(String json) {
    final dictionary = jsonDecode(json) as Map<String, dynamic>;
    String messageId = dictionary["messageId"];
    int campaignId = dictionary["campaignId"];
    // IterableInAppContent content = IterableInAppContent.from(
    //     Map<String, Object>.from(dictionary["content"]));
    IterableInAppTrigger trigger = IterableInAppTrigger.from(
        const JsonEncoder().convert(dictionary["trigger"]));
    bool saveToInbox = dictionary["saveToInbox"];
    Map<String, Object>? customPayload =
        Map<String, Object>.from(dictionary["customPayload"]);
    bool read = dictionary["read"];
    double priorityLevel = dictionary["priorityLevel"];
    DateTime createdAt =
        DateTime.fromMillisecondsSinceEpoch(dictionary["createdAt"]).toUtc();
    DateTime expiresAt =
        DateTime.fromMillisecondsSinceEpoch(dictionary["expiresAt"]).toUtc();
    IterableInboxMetadata? inboxMetadata = dictionary["inboxMetadata"] != null
        ? IterableInboxMetadata.from(
            Map<String, Object>.from(dictionary["inboxMetadata"]))
        : null;

    return IterableInAppMessage(messageId, campaignId, /*content,*/ trigger,
        saveToInbox, read, priorityLevel,
        createdAt: createdAt,
        expiresAt: expiresAt,
        inboxMetadata: inboxMetadata,
        customPayload: customPayload);
  }
}

// In App Manager
class IterableInAppManager {
  static const MethodChannel _channel = MethodChannel('iterable');

  /// Returns a [Future<List<dynamic>>] of all in-app messages
  Future<List<IterableInAppMessage>> getMessages() async {
    IterableInAppMessage convertedMsg;
    List<IterableInAppMessage> outgoingMsgs = [];
    var incomingMsgs = await _channel.invokeMethod('getInAppMessages');
    incomingMsgs.forEach((message) => {
          convertedMsg =
              IterableInAppMessage.from(const JsonEncoder().convert(message)),
          outgoingMsgs.add(convertedMsg)
        });
    return outgoingMsgs;
  }
}
