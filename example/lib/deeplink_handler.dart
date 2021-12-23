import 'package:flutter/foundation.dart';

enum TabIndexType { home, products, events }

class TabIndex {
  late TabIndexType type;

  TabIndex({required this.type});

  int toInt() {
    return type.index;
  }

  TabIndex.fromIndex(int index) {
    type = TabIndexType.values[index];
  }

  static TabIndex from(String urlComponent) {
    switch (urlComponent) {
      case 'products':
        return TabIndex.fromIndex(1);
      case 'events':
        return TabIndex.fromIndex(2);
      default:
        return TabIndex.fromIndex(0);
    }
  }
}

class DeeplinkHandler {
  static TabIndex handle(String deeplink) {
    List<String> components = deeplink.split("/");
    if (components.length >= 4) {
      return TabIndex.from(components[3]);
    } else {
      return TabIndex.fromIndex(0);
    }
  }
}
