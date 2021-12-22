import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:iterable/iterable.dart';
import 'package:iterable/common.dart';
import 'env.dart'; // TODO: Update env.example.dart
import 'iterable_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final config = IterableConfig(inAppDisplayInterval: 1.0);

  @override
  void initState() {
    super.initState();
  }

  ListView _identityListView() {
    // Create IterableConfig with desired settings
    // var config = IterableConfig();
    // config.inAppDisplayInterval = 1.0;

    // Set up custom handling for in-app messages
    IterableInAppShowResponse inAppHandler(IterableInAppMessage message) {
      debugPrint(
          "🔥inAppDelegate Callback - message.customPayload: ${message.customPayload}");
      debugPrint(
          "🔥inAppDelegate Callback - message.customPayload.shouldSkip: ${message.customPayload?["shouldSkip"]}");
      if (message.customPayload?["shouldSkip"] == true) {
        return IterableInAppShowResponse.skip;
      } else {
        return IterableInAppShowResponse.show;
      }
    }

    config.inAppDelegate = inAppHandler;

    // Initialize Iterable
    Iterable.initialize(IterableEnv.apiKey, config).then((success) => {
          if (success) {debugPrint('Iterable Initialized')}
        });

    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        const Padding(padding: EdgeInsets.all(3.5)),
        // Identity Tab
        // Set either email OR userId for a user
        IterableButton(
            title: 'Set Email',
            onPressed: () =>
                Iterable.setEmail("christina.schell+flutter7@iterable.com")),
        IterableButton(
            title: 'Set User Id',
            onPressed: () => Iterable.setUserId("flutterUserId2")),
        // 2. [DONE] Get user email
        IterableButton(
            title: 'Get Email',
            onPressed: () => Iterable.getEmail()
                .then((email) => debugPrint('Current Email: $email'))),
        // 3. [DONE] Get user id
        IterableButton(
            title: 'Get User Id',
            onPressed: () => Iterable.getUserId()
                .then((userId) => debugPrint('Current User Id: $userId'))),
        // 4. [DONE] Update user email
        IterableButton(
            title: 'Update Email',
            onPressed: () =>
                Iterable.updateEmail("christina.schell+flutter8@iterable.com")
                    .then((response) => debugPrint(jsonEncode(response)))),
        // 5. [DONE] Update user data
        IterableButton(
            title: 'Update User Data',
            onPressed: () =>
                Iterable.updateUser({'newFlutterKey': 'def123'}, false)
                    .then((response) => debugPrint(jsonEncode(response)))),
        // 14. [DONE] Update user subscriptions (Settings tab)
        IterableButton(
            title: 'Update User Subscriptions',
            onPressed: () => Iterable.updateSubscriptions(
                emailListIds: [1234],
                subscribedMessageTypeIds: [12345],
                unsubscribedChannelIds: [67890],
                unsubscribedMessageTypeIds: [78901])),
        // [DONE] Set email and user id
        IterableButton(
            title: 'Set Email and User Id',
            onPressed: () => {
                  Iterable.setEmailAndUserId(
                          "christina.schell+flutter6@iterable.com",
                          "flutterUserId3")
                      .then((response) => debugPrint(jsonEncode(response)))
                }),
        // 8. Push
        //  - [DONE] Foundation
        //  - [DONE] Rich Push
        // 9. InApp
        //  - [DONE] Foundation
        // 15. [DONE] Update user methods to return Future<string> of full error/success payloads
      ],
    );
  }

  ListView _commerceListView() {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      const Padding(padding: EdgeInsets.all(3.5)),
      // E-Commerce Tab
      // 6. [DONE] Use the Commerce API to track updates to the cart (add/remove/update qty)
      // 7. [DONE] Use the Commerce API to track a purchase
      IterableButton(
          title: 'Add To Cart',
          onPressed: () => Iterable.updateCart(_addToCartItems())),
      IterableButton(
          title: 'Remove From Cart',
          onPressed: () => Iterable.updateCart(_removeFromCartItems())),
      IterableButton(
          title: 'Update Quantity',
          onPressed: () => Iterable.updateCart(_updateQtyItems())),
      IterableButton(
          title: 'Track Purchase',
          onPressed: () =>
              Iterable.trackPurchase(19.98, _purchaseItems(), {'rewards': 100}))
    ]);
  }

  ListView _settingsListView() {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      const Padding(padding: EdgeInsets.all(3.5)),
      // Other Tab
      // 1. [DONE] Track a custom event
      IterableButton(
          title: 'Track Event',
          onPressed: () => Iterable.trackEvent(
              'Test Event From Flutter', {'eventDataField': 'abc123'})),
      // 10. [DONE] Get last push payload
      IterableButton(
          title: 'Get Last Push Payload',
          onPressed: () => {
                Iterable.getLastPushPayload().then(
                    (payload) => debugPrint('Last Push Payload: $payload'))
              }),
      // 11. [DONE] Deeplinking
      // 12. [DONE] Expose getMessages method
      // [DONE - NEED TO TEST] Other methods that RN exposes (trackInApp, trackPushOpen, etc)
      // 15. Implement delegates/listeners
      // Implement JWT Authentication
      // Deeplink handle method
      // 13. [MAYBE] Restyle and set up more realistic Sample app
      // TEST! TEST! TEST!
      IterableButton(
          title: 'Get In App Messages',
          onPressed: () => {
                Iterable.inAppManager
                    .getMessages()
                    .then((messages) => _logInAppMessages(messages))
              }),
      IterableButton(
          title: 'Show In App Message',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Show Message")}
                      else
                        {
                          Iterable.inAppManager
                              .showMessage(messages.first, true)
                        }
                    })
              }),
      IterableButton(
          title: 'Remove In App Message',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Remove Message")}
                      else
                        {
                          Iterable.inAppManager.removeMessage(
                              messages.first,
                              IterableInAppLocation.inApp,
                              IterableInAppDeleteSource.deleteButton)
                        }
                    })
              }),
      IterableButton(
          title: 'Set Read For Message',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Set Read For Message")}
                      else
                        {
                          Iterable.inAppManager
                              .setReadForMessage(messages.first, true)
                        }
                    })
              }),
      IterableButton(
          title: 'Get HTML Content For Message',
          onPressed: () => {
                Iterable.inAppManager.getMessages().then((messages) => {
                      if (messages.isEmpty)
                        {_logInAppError("Get HTML Content For Message")}
                      else
                        {
                          Iterable.inAppManager
                              .getHtmlContentForMessage(messages.first)
                              .then((content) =>
                                  debugPrint(jsonEncode((content.toJson()))))
                        }
                    })
              }),
      IterableButton(
          title: 'Set Auto Display Paused',
          onPressed: () => Iterable.inAppManager.setAutoDisplayPaused(true))
    ]);
  }

  // Helper Methods
  List<IterableCommerceItem> _addToCartItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 1,
          sku: "abcsku123",
          categories: ["category1", "category2"],
          dataFields: {"someItemKey1": "someItemValue1"}),
      IterableCommerceItem("def456", "ABC", 19.99, 2,
          sku: "defsku456",
          categories: ["category3", "category4"],
          dataFields: {"someItemKey2": "someItemValue2"})
    ];
  }

  List<IterableCommerceItem> _removeFromCartItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 1,
          sku: "abcsku123",
          categories: ["category1", "category2"],
          dataFields: {"someItemKey1": "someItemValue1"})
    ];
  }

  List<IterableCommerceItem> _updateQtyItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 2,
          sku: "abcsku123",
          categories: ["category1", "category2"],
          dataFields: {"someItemKey1": "someItemValue1"}),
    ];
  }

  List<IterableCommerceItem> _purchaseItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 2,
          sku: "abcsku123",
          categories: ["category1", "category2"],
          dataFields: {"someItemKey1": "someItemValue1"})
    ];
  }

  void _logInAppError(String message) {
    debugPrint("$message Failed. There are no in-app messages in the queue.");
  }

  void _logInAppMessages(List<IterableInAppMessage> messages) {
    debugPrint('========= In-App Messages =========');
    messages.asMap().forEach((index, message) => {
          debugPrint('message #${index + 1}:'),
          developer.log(jsonEncode((message.toJson())))
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.shopping_cart)),
                Tab(icon: Icon(Icons.format_list_bulleted)),
              ],
            ),
            title: const Text('Iterable Flutter Example'),
          ),
          body: TabBarView(
            children: [
              _identityListView(),
              _commerceListView(),
              _settingsListView(),
            ],
          ),
        ),
      ),
    );
  }
}
