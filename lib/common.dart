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
      [bool? remoteNotificationsEnabled,
      String? pushIntegrationName,
      String? urlHandlerPresent,
      String? customActionHandlerPresent,
      String? inAppHandlerPresent,
      String? authHandlerPresent,
      bool? autoPushRegistration,
      double? inAppDisplayInterval,
      double? expiringAuthTokenRefreshPeriod,
      IterableLogLevel? logLevel]) {
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
      [String? sku,
      String? description,
      String? url,
      String? imageUrl,
      List<String>? categories,
      Map<String, Object>? dataFields]) {
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
