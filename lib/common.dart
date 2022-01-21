import 'inapp/inapp_common.dart';
// ignore_for_file: prefer_initializing_formals

typedef IterableInAppHandler = IterableInAppShowResponse Function(
    IterableInAppMessage msg);
typedef IterableCustomActionHandler = bool Function(
    IterableAction action, IterableActionContext context);
typedef IterableUrlHandler = bool Function(
    String url, IterableActionContext context);
typedef IterableAuthHandler = Future<String> Function();

class EventListenerNames {
  static const name = 'emitterName';
  static const inAppHandler = 'IterableFlutter.InAppDelegateEvent';
  static const customActionHandler =
      'IterableFlutter.CustomActionDelegateEvent';
  static const urlHandler = 'IterableFlutter.UrlDelegateEvent';
  static const authHandler = 'IterableFlutter.AuthDelegateEvent';
}

class Utilities {
  static T? cast<T>(x) => x is T ? x : null;
}

class IterableConfig {
  String? pushIntegrationName;
  bool? autoPushRegistration; // default true
  double? inAppDisplayInterval;
  double? expiringAuthTokenRefreshPeriod;
  int? logLevel;
  List<String>? allowedProtocols;
  IterableInAppHandler? inAppHandler;
  IterableCustomActionHandler? customActionHandler;
  IterableUrlHandler? urlHandler;
  IterableAuthHandler? authHandler;

  IterableConfig(
      {String? pushIntegrationName,
      bool? autoPushRegistration,
      double? inAppDisplayInterval,
      double? expiringAuthTokenRefreshPeriod,
      IterableLogLevel? logLevel,
      List<String>? allowedProtocols,
      IterableInAppHandler? inAppHandler,
      IterableCustomActionHandler? customActionHandler,
      IterableUrlHandler? urlHandler,
      IterableAuthHandler? authHandler}) {
    this.pushIntegrationName = pushIntegrationName;
    this.autoPushRegistration = autoPushRegistration;
    this.inAppDisplayInterval = inAppDisplayInterval;
    this.expiringAuthTokenRefreshPeriod = expiringAuthTokenRefreshPeriod;
    this.logLevel = logLevel?.toInt() ?? IterableLogLevel.info.toInt();
    this.allowedProtocols = allowedProtocols;
    this.inAppHandler = inAppHandler;
    this.customActionHandler = customActionHandler;
    this.urlHandler = urlHandler;
    this.authHandler = authHandler;
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
