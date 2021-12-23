import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore_for_file: prefer_initializing_formals

typedef InAppHandlerCallback = IterableInAppShowResponse Function(
    IterableInAppMessage msg);
typedef UrlHandlerCallback = bool Function(
    String url, IterableActionContext context);

class Utilities {
  static T? cast<T>(x) => x is T ? x : null;
}

class EventListenerNames {
  static const name = 'emitterName';
  static const inAppHandler = 'IterableFlutter.InAppDelegateEvent';
  static const urlHandler = 'IterableFlutter.UrlDelegateEvent';
  static const authHandler = 'IterableFlutter.AuthDelegateEvent';
}

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
  InAppHandlerCallback? inAppDelegate;
  UrlHandlerCallback? urlHandler;

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
      IterableLogLevel? logLevel,
      InAppHandlerCallback? inAppDelegate}) {
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
    this.inAppDelegate = inAppDelegate;
  }
}

enum ActionSourceType { push, appLink, inApp }

class IterableActionSource {
  late ActionSourceType type;

  IterableActionSource({required this.type});

  int toInt() {
    return type.index;
  }

  IterableActionSource.fromIndex(int index) {
    type = ActionSourceType.values[index];
  }

  static IterableActionSource from(int number) {
    return IterableActionSource.fromIndex(number);
  }
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
  // Map<String, dynamic> toJson() =>
  //     {'type': type, 'data': data, 'userInput': userInput};

  static IterableAction from(Map<String, dynamic> dictionary) {
    return IterableAction(dictionary["type"],
        data: dictionary["data"], userInput: dictionary["userInput"]);
  }
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

  static IterableActionContext from(Map<String, dynamic> dictionary) {
    IterableAction action = IterableAction.from(dictionary["action"]);
    IterableActionSource source =
        IterableActionSource.from(dictionary["source"]);
    return IterableActionContext(action, source);
  }
}

class IterableAttributionInfo {
  late int campaignId;
  late int templateId;
  late String messageId;

  IterableAttributionInfo(int campaignId, int templateId, String messageId) {
    this.campaignId = campaignId;
    this.templateId = templateId;
    this.messageId = messageId;
  }

  Map<String, dynamic> toJson() => {
        'campaignId': campaignId,
        'templateId': templateId,
        'messageId': messageId
      };
}

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

class IterableInAppShowResponse {
  final int _value;

  const IterableInAppShowResponse._(this._value);

  int toInt() {
    return _value;
  }

  static const IterableInAppShowResponse show = IterableInAppShowResponse._(0);
  static const IterableInAppShowResponse skip = IterableInAppShowResponse._(1);
}

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

enum InAppContentType { html, alert, banner }

class IterableInAppContentType {
  late InAppContentType type;

  IterableInAppContentType({required this.type});

  int toInt() {
    return type.index;
  }

  IterableInAppContentType.fromIndex(int index) {
    type = InAppContentType.values[index];
  }

  static IterableInAppContentType from(int number) {
    return IterableInAppContentType.fromIndex(number);
  }
}

class IterableInAppLocation {
  final int _value;

  const IterableInAppLocation._(this._value);

  int toInt() {
    return _value;
  }

  static const IterableInAppLocation inApp = IterableInAppLocation._(0);
  static const IterableInAppLocation inbox = IterableInAppLocation._(1);
}

class IterableInAppCloseSource {
  final int _value;

  const IterableInAppCloseSource._(this._value);

  int toInt() {
    return _value;
  }

  static const IterableInAppCloseSource back = IterableInAppCloseSource._(0);
  static const IterableInAppCloseSource link = IterableInAppCloseSource._(1);
  static const IterableInAppCloseSource unknown =
      IterableInAppCloseSource._(100);
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

class IterableEdgeInsets {
  late double top;
  late double left;
  late double bottom;
  late double right;

  IterableEdgeInsets(double top, double left, double bottom, double right) {
    this.top = top;
    this.left = left;
    this.bottom = bottom;
    this.right = right;
  }

  // Debug purposes only
  dynamic toJson() {
    return {'top': top, 'left': left, 'bottom': bottom, 'right': right};
  }

  static IterableEdgeInsets from(String json) {
    final decodedEdgeInsets = jsonDecode(json) as Map<String, dynamic>;
    return IterableEdgeInsets(
        decodedEdgeInsets["top"].toDouble(),
        decodedEdgeInsets["left"].toDouble(),
        decodedEdgeInsets["bottom"].toDouble(),
        decodedEdgeInsets["right"].toDouble());
  }

  static double convertToDouble(dynamic number) {
    final double? result = Utilities.cast(number);
    return (result != null) ? result : 0.0;
  }
}

class IterableInAppContent {
  late IterableInAppContentType type;
}

class IterableHtmlInAppContent implements IterableInAppContent {
  @override
  late IterableInAppContentType type;
  late IterableEdgeInsets edgeInsets;
  late String html;

  IterableHtmlInAppContent(IterableInAppContentType type,
      IterableEdgeInsets edgeInsets, String html) {
    this.type = type;
    this.edgeInsets = edgeInsets;
    this.html = html;
  }

  // Debug purposes only
  dynamic toJson() {
    return {
      'type': type.toInt(),
      'edgeInsets': edgeInsets.toJson(),
      'html': html
    };
  }

  static IterableHtmlInAppContent from(Map<String, dynamic> dictionary) {
    var encodedEdgeInsets = jsonEncode(dictionary["edgeInsets"]);
    return IterableHtmlInAppContent(
        IterableInAppContentType.from(dictionary["type"] as int),
        IterableEdgeInsets.from(encodedEdgeInsets),
        dictionary["html"] as String);
  }
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

// In App Message
class IterableInAppMessage {
  late String messageId;
  late int campaignId;
  late IterableHtmlInAppContent content;
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
      IterableHtmlInAppContent content,
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
    this.content = content;
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
      'content': content,
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
    int campaignId = dictionary["campaignId"] ?? 0;
    IterableHtmlInAppContent content = IterableHtmlInAppContent.from(
        Map<String, Object>.from(dictionary["content"]));
    IterableInAppTrigger trigger =
        IterableInAppTrigger.from(jsonEncode(dictionary["trigger"]));
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

    return IterableInAppMessage(messageId, campaignId, content, trigger,
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

  /// Returns a [Future<List<IterableInAppMessage>>] of all in-app messages
  Future<List<IterableInAppMessage>> getMessages() async {
    IterableInAppMessage convertedMsg;
    List<IterableInAppMessage> outgoingMsgs = [];
    var incomingMsgs = await _channel.invokeMethod('getInAppMessages');
    debugPrint("# of in app messages: ${incomingMsgs.toList().length}");
    incomingMsgs.forEach((message) => {
          convertedMsg = IterableInAppMessage.from(jsonEncode(message)),
          outgoingMsgs.add(convertedMsg)
        });
    return outgoingMsgs;
  }

  /// Shows in app [message]
  Future<String?> showMessage(
      IterableInAppMessage message, bool consume) async {
    return await _channel.invokeMethod(
        'showMessage', {'messageId': message.messageId, 'consume': consume});
  }

  /// Remove in app [message]
  void removeMessage(IterableInAppMessage message,
      IterableInAppLocation location, IterableInAppDeleteSource source) {
    _channel.invokeMethod('removeMessage', {
      'messageId': message.messageId,
      'location': location.toInt(),
      'source': source.toInt()
    });
  }

  /// Sets the read flag for an in app [message]
  void setReadForMessage(IterableInAppMessage message, bool read) {
    _channel.invokeMethod(
        'setReadForMessage', {'messageId': message.messageId, 'read': read});
  }

  /// Gets the [IterableHtmlInAppContent] for a message
  Future<IterableHtmlInAppContent> getHtmlContentForMessage(
      IterableInAppMessage message) async {
    var htmlContentString = await _channel.invokeMethod(
        'getHtmlContentForMessage', {'messageId': message.messageId});
    final dictionary = jsonDecode(htmlContentString) as Map<String, dynamic>;
    return IterableHtmlInAppContent.from(dictionary);
  }

  /// Pauses auto display for in-app messages
  void setAutoDisplayPaused(bool paused) {
    _channel.invokeMethod('setAutoDisplayPaused', {'paused': paused});
  }
}
