import 'dart:convert';

import '../common.dart';

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

  IterableEdgeInsets(this.top, this.left, this.bottom, this.right);

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
  IterableInAppContentType type = IterableInAppContentType.from(0);
  late IterableEdgeInsets edgeInsets;
  late String html;

  IterableHtmlInAppContent(this.edgeInsets, this.html);

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
    return IterableHtmlInAppContent(IterableEdgeInsets.from(encodedEdgeInsets),
        dictionary["html"] as String);
  }
}

class IterableInboxMetadata {
  String? title;
  String? subtitle;
  String? icon;

  IterableInboxMetadata(this.title, this.subtitle, this.icon);

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

  IterableInAppMessage(this.messageId, this.campaignId, this.content,
      this.trigger, this.saveToInbox, this.read, this.priorityLevel,
      {DateTime? createdAt,
      DateTime? expiresAt,
      IterableInboxMetadata? inboxMetadata,
      Map<String, Object>? customPayload}) {
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
