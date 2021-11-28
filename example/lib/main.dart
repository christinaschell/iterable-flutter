import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:iterable/iterable.dart';
import 'package:iterable/common.dart';
import 'env.dart'; // TODO: Update env.example.dart
import 'iterable_button.dart';

// FIRST: Try to register for push on simulator again, otherwise set up FCM

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');

  // Create IterableConfig with desired settings
  var config = IterableConfig();

  @override
  void initState() {
    super.initState();
  }

  ListView _identityListView() {
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
                Iterable.setEmail("christina.schell+flutter@iterable.com")),
        IterableButton(
            title: 'Set User Id',
            onPressed: () => Iterable.setUserId("flutterUserId1")),
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
                Iterable.updateEmail("christina.schell+flutter2@iterable.com")
                    .then((response) => debugPrint(encoder.convert(response)))),
        // 5. [DONE] Update user data
        IterableButton(
            title: 'Update User Data',
            onPressed: () =>
                Iterable.updateUser({'newFlutterKey': 'def123'}, false)
                    .then((response) => debugPrint(encoder.convert(response)))),
        IterableButton(
            title: 'Set Email and User Id',
            onPressed: () => {
                  Iterable.setEmailAndUserId(
                          "christina.schell+flutter3@iterable.com",
                          "flutterUserId2")
                      .then((response) => debugPrint(encoder.convert(response)))
                }),
        // 8. Push
        //  - [DONE] Foundation
        //  - [DONE] Rich Push
        //  - try with FCM
        // 9. InApp
        //  - [DONE] Foundation
        //  - try with FCM
        // 13. Restyle and set up more realistic Sample app
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
                Iterable.getLastPushPayload()
                    .then((payload) => debugPrint(encoder.convert(payload)))
              })
      // 11. Deeplinking
      // 12. Expose getMessages method
      // 14. Update user subscriptions (Settings tab)
      // 15. Implement delegates/listeners
    ]);
  }

  // Helper Methods
  List<IterableCommerceItem> _addToCartItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 1, "abcsku123", null, null,
          null, ["category1", "category2"], {"someItemKey1": "someItemValue1"}),
      IterableCommerceItem("def456", "ABC", 19.99, 2, "defsku456", null, null,
          null, ["category3", "category4"], {"someItemKey2": "someItemValue2"})
    ];
  }

  List<IterableCommerceItem> _removeFromCartItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 1, "abcsku123", null, null,
          null, ["category1", "category2"], {"someItemKey1": "someItemValue1"})
    ];
  }

  List<IterableCommerceItem> _updateQtyItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 2, "abcsku123", null, null,
          null, ["category1", "category2"], {"someItemKey1": "someItemValue1"}),
    ];
  }

  List<IterableCommerceItem> _purchaseItems() {
    return [
      IterableCommerceItem("abc123", "ABC", 9.99, 2, "abcsku123", null, null,
          null, ["category1", "category2"], {"someItemKey1": "someItemValue1"})
    ];
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
            title: const Text('Iterable Flutter Donut Shop'),
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
