
![Iterable-Logo](https://user-images.githubusercontent.com/7387001/129065810-44b39e27-e319-408c-b87c-4d6b37e1f3b2.png)

# Iterable's Flutter SDK

[Iterable](https://www.iterable.com) is a growth marketing platform that helps you to create better experiences for—and deeper relationships with—your customers. Use it to send customized email, SMS, push notification, and in-app message campaigns to your customers.

This SDK helps you integrate your Flutter apps with Iterable.

# Table of Contents

* [Installation](#installation)
* [API](#api)
* [Usage](#usage)
* [FAQ](#faq)
* [Contributing](#contributing)
* [License](#license)

# Current TODOs
#### Note: Remove this section when ready to go live

* Create a new package/example app that doesn't have schelly in the name. Could possibly be done by refactor/rename in IDEs
* Create and work out of a new private repo on GitHub under the Iterable org
* Create App ID/Certificates within the Iterable Apple Developer Account
* Use engineering org as a test account (currently using Flutter Dev within training@iterable.com)
* **UNIT AND INTEGRATION TESTS!!! Super important!**
* **Bug fixes**
* Test out using Firebase for the iOS push since Flutter devs will be more familiar with Firebase and will be able to hold their configs in one place. 
* A more public facing sample app that is in line with the other "Coffee" style apps for other SDKs
* **Public facing docs.** These will be similar to the React Native Docs since this repo mirrors that
* **Implement Mobile Inbox**
* Add `CONTRIBUTING.md`
* Add `FAQs`

##### Dartdoc
Class level documentation was already created using [`dartdoc`](https://pub.dev/packages/dartdoc). This documentation generates method and type definitions in the same format that is on `docs.flutter.io`. If we want to use these, they just need to be published to a domain. Our own documentation will likely be more comprehensive and prescriptive. If we decide not to use the dartdoc docs, the `docs` directory it can be removed from this repo (or simply added to `.gitignore`).


# Installation

#### ***While Still in Development***
##### Note: Remove this section when ready to go live

1. Install Flutter and set up your environment
2. Download VS Code and install the Flutter plugin 
3. Clone the repo
4. Run `flutter pub get` in the root
4. Within the `example/ios` folder, run `pod install`
5. Open the root folder in VS Code
6. Update the `env.example.dart` with: 
	- Your own API Keys (JWT and regular)
	- your JWT token that you manually create on `jwt.io`
	- Three unique email addresses in order to test the update methods
	- Update the name of the file to `env.dart` (example)
6. Use the Terminal to `cd` into the `example/ios` directory
7. Run `pod install && cd .. && flutter run`

When you want to debug the native plugin code, you will want to open the native projects (in the `example/android` and `example/ios` folders in [Android Studio](https://docs.flutter.dev/development/tools/android-studio#run-app-with-breakpoints) and [Xcode](https://stackoverflow.com/a/66021238).

When debugging the Flutter (Dart) side, debugging will be best done in [VS Code](https://docs.flutter.dev/development/tools/vs-code#run-app-with-breakpoints).

#### Example env.dart

```
class IterableEnv {
  static const apiKey = "YOUR_API_KEY";
  static const jwtApiKey = "YOUR_JWT_API_KEY";
  static const jwtToken =
      "YOU_JWT_TOKEN";
  static const email = "flutter.example@iterable.com";
  static const email2 = "flutter.example2@iterable.com";
  static const email3 = "flutter.example3@iterable.com";
}
```


#### ***When Published Live***

In your Flutter app project, update the `pubspec.yaml` file to add the Iterable Flutter plugin dependency as follows:

```
  dependencies:
	flutter:
		sdk: flutter
	iterable: '1.0.0'
```

To pull the Iterable Flutter plugin dependency in your project, run the following command:

`flutter pub get`

Import the Dart code to your project:

```
import 'package:iterable/iterable_api.dart';
import 'package:iterable/common.dart';
import 'package:iterable/inapp/inapp_common.dart';
```

# API

Below are the methods this SDK exposes. See [Iterable's API Docs](https://api.iterable.com/api/docs) for information on what data to pass and what payload to receive from the HTTP requests.

## Iterable
Static methods available within the `Iterable` class.


| Method Name           	| Description                                                                                                               	|
|-----------------------	|---------------------------------------------------------------------------------------------------------------------------	|
| [`initialize`](#initialize)        	| Initialize the Iterable SDK with an [`IterableConfig`](#iterableConfig) object and `apiKey`                                                                           	|
| [`setEmail`](#setEmail)        	| Identify a user with an email address as the primary identifier                                                                           	|
| [`setUserId`](#setUserId)        	| Identify a user with a userId as the primary identifier                                                                           	|
| [`setEmailAndUserId `](#setEmailAndUserId)        	| Identify a user with both an email and a userId	|
| [`getEmail`](#getEmail)        	| Get the current email address for the user                                                              	|
| [`getUserId`](#getUserId)        	| Get the current userId for the user                                                      	|
| [`updateEmail`](#updateEmail)     	| Change a user's email address                                                                                             	|
| [`updateUser`](#updateUser)          	| Change data on a user's profile or create a user if none exists                                                           	|
| [`updateSubscriptions`](#updateSubscriptions) 	| Updates user's subscriptions                                                                                              	|
| [`trackEvent `](#trackEvent)               	| Track custom events |
| [`updateCart`](#updateCart)          	| Update _shoppingCartItems_ field on user profile                                                                          	|
| [`trackPurchase`](#trackPurchase)       	| Track purchase events                                                                                                                                                                                                         	|
| [`trackPushOpenWithCampaignId`](#trackPushOpenWithCampaignId)       	| Iterable's SDK automatically tracks push notification opens. However, it's also possible to manually track these events by calling this method	|
| [`getLastPushPayload`](#getLastPushPayload)       	| Get the payload associated with the most recent push notification with which the user opened the app (by clicking an action button, etc.)	|
| [`disableDeviceForCurrentUser`](#disableDeviceForCurrentUser)       	| Manually disables push notifications for the device	|
| [`trackInAppOpen`](#trackInAppOpen)      	| Track when a message is opened and marks it as read                                                                       	|
| [`trackInAppClick`](#trackInAppClick)     	| Track when a user clicks on a button or link within a message                                                             	|
| [`trackInAppClose `](#trackInAppClose)  	| Track when an in-app message is closed                                                               	|
| [`inAppConsume `](#inAppConsume)   	| Track when a message has been consumed. Deletes the in-app message from the server so it won't be returned anymore        	|
| [`getAttributionInfo `](#getAttributionInfo)    	| To get the current attribution information (based on a recent deep link click) 	|
| [`setAttributionInfo `](#setAttributionInfo)    	| To manually set the current attribution information so that it can later be used when tracking events 	|

## IterableInAppManager
Static methods available on the `inAppManager` property within the `Iterable` class.


| Method Name           	| Description                                                                                                               	|
|-----------------------	|---------------------------------------------------------------------------------------------------------------------------	|
| [`getInAppMessages`](#getInAppMessages)    	| Returns all of the in-app messages for the user 	|
| [`showMessage`](#showMessage)     	| Shows an in-app message that had been skipped previously.                                                             	|
| [`removeMessage`](#removeMessage)     	| Removes the specified message from the user's message queue                                                                                    	|
| [`setReadForMessage`](#setReadForMessage)     	| Sets the `read` property for a given message. Used when maintaining a messaging inbox.	|
| [`getHtmlContentForMessage`](#getHtmlContentForMessage)     	| Gets the HTML content of an in-app message	|
| [`setAutoDisplayPaused`](#setAutoDisplayPaused)     	| Sets whether or not the in-apps should be displayed automatically	|


## IterableConfig
Optional configuration settings available pre-initialization.

| Name                      | Type                                                                                                                                                                                                                     | Description                                                           | Default   |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|-----------|
| pushIntegrationName           |  `String` | The name of the corresponding push integration that has been configured in Iterable                                                                                                                                                | The package name or bundle id of your native project     |
| autoPushRegistration | `bool` |When `true`, causes the SDK to automatically register and deregister for push tokens when you provide email or userId values to the SDK                                                                                                                                               | `true` |
| inAppDisplayInterval                                                                                  | `double`           | When displaying multiple in-app messages in sequence, the number of seconds to wait between each                                                     | `30.0` |
| expiringAuthTokenRefreshPeriod                                                                                      | `double`  | The number of seconds before the current JWT's expiration that the SDK should call the `authHandler` to get an updated JWT.                                                           | `60.0` |
| logLevel              |  [`IterableLogLevel`](#loglevel) | The level of logging                                                                                             |                                                           `IterableLogLevel.error` |
| allowedProtocols               | `List<String>`                                                          | Specific URL protocols that the SDK can expect to see on incoming links (and that it should handle as needed).                                                                    | `["https", "action", "itbl", "iterable"]` |
| inAppHandler         |  [`IterableInAppHandler`](#iterableinapphandler)      | Implement this property to override default in-app message behavior.                                                                                                                                                   |                                                          |
| customActionHandler               |  [`IterableCustomActionHandler`](#iterablecustomactionhandler) | Use this method to determine whether or not the app can handle the clicked custom action URL. If it can, it should handle the action and return `true`. Otherwise, it should return `false` ||
| urlHandler               |[`IterableUrlHandler`](#iterableurlhandler) |  Use this method to determine whether or not the app can handle the clicked URL. If it can, the method should navigate the user to the right content in the app and return `true`. Otherwise, it should return `false` to have the web browser open the URL. ||
| authHandler               |  [`IterableAuthHandler`](#iterableauthhandler) | Provides a JWT to Iterable's Flutter SDK, which can then append the JWT to subsequent API requests. The SDK automatically calls authHandler at various times. |  |

## IterableInAppHandler

When Iterable retrieves in-app messages, it passes them to the function stored in the `inAppHandler` property of the [`IterableConfig`](#iterableconfig) object that was passed to the SDK's `initialize`method.

Implement this property to override default in-app message behavior. For example, you might use the `customPayload` associated with an incoming message to choose whether or not to display it, or you might inspect the `priorityLevel` property to determine the message's priority.

```
IterableInAppShowResponse Function(IterableInAppMessage msg)
```

Example:

```
 final config = IterableConfig();
 
 IterableInAppShowResponse inAppHandler(IterableInAppMessage message) {
    if (message.customPayload?["shouldSkip"] == true) {
      return IterableInAppShowResponse.skip;
    } else {
      return IterableInAppShowResponse.show;
    }
  }
  
  config.inAppHandler = inAppHandler;
  
```


## IterableCustomActionHandler

To handle custom action URLs, provide a function to the `customActionHandler` property on the [`IterableConfig`](#iterableconfig) object passed to the SDK's `initialize` method. Iterable calls this method when a user clicks a URL, passing in the URL and other contextual information.

Use this method to determine whether or not the app can handle the clicked custom action URL. If it can, it should handle the action and return `true`. Otherwise, it should return `false`.

```
bool Function(IterableAction action, IterableActionContext context);
```

Example:

```
  final config = IterableConfig();

  bool customActionHandler(IterableAction action, IterableActionContext actionContext) {
    if (action.type.contains("discount?promo=")) {
      String promoCode = action.type.split("?promo=")[1];
      _showAlert(promoCode);
      return true;
    }
    return false;
  }
  
  config.customActionHandler = customActionHandler;
  
```

## IterableUrlHandler

To handle deep links (and other URLs), Iterable calls the function stored in the [`IterableConfig`](#iterableconfig) object's `urlHandler`. Set this property on the `IterableConfig` you provide to the SDK's initialize method.

Use this method to determine whether or not the app can handle the clicked URL. If it can, the method should navigate the user to the right content in the app and return `true`. Otherwise, it should return `false` to have the web browser open the URL.

```
bool Function(String url, IterableActionContext context);
```

Example:

```
  final config = IterableConfig();
  
  bool urlHandler(String url, IterableActionContext context) {
    int tabIndex = DeeplinkHandler.handle(url).toInt();
    _tabController.animateTo(tabIndex);
    return true;
  }
  
  config.urlHandler = urlHandler;
    
```  

## IterableAuthHandler

A function expression that provides a valid JWT for the app's current user to Iterable's Flutter SDK. Provide an implementation for this method only if your app uses a [JWT-enabled API key](https://support.iterable.com/hc/articles/360050801231).

```
Future<String> Function();
```

Example:

```
  final config = IterableConfig();
  
Future<String> authHandler() async {

    // This is simulating async retrieval of a JWT token from your server.
    // An actual implementation would take an email or userId, and
    // return the token. For even more security, require a username/password
    // for your JWT retrieval endpoint.
    
    return await Future.delayed(
            const Duration(milliseconds: 100), () => 'YOUR_JWT_TOKEN')
        .catchError((err) {
      debugPrint("Error retrieving JWT from server: $err");
    });
  }
  
  config.authHandler = authHandler;
    
```  

This example demonstrates how an app that uses a JWT-enabled API key might initialize the SDK. To make requests to Iterable's API using a JWT-enabled API key, you should first fetch a valid JWT for your app's current user from your own server, which must generate it. The `authHandler` provides this JWT to Iterable, which can then append the JWT to subsequent API requests. The SDK automatically calls `authHandler` at various times:

* When your app sets the user's email or user ID.
* When your app updates the user's email.
* Before the current JWT expires (at a configurable interval set by [`expiringAuthTokenRefreshPeriod`](#expiringAuthTokenRefreshPeriod))
When your app receives a 401 response from Iterable's API with a `InvalidJwtPayload` error code. However, if the SDK receives a second consecutive 401 with an `InvalidJwtPayload` error when it makes a request with the new token, it won't call the `authHandler` again until you call [`setEmail`](#setemail) or [`setUserId`](#setuserid).


## IterableLogLevel
Specifies how much information is logged.

The following logging levels are available:

| Value                     | Description                                                                                                                                                                                                                      
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `IterableLogLevel.info` | Informational events that highlight the progress of the application |
| `IterableLogLevel.debug` | Debug-level events used for debugging an application |  
| `IterableLogLevel.error` | Error events such as critical errors and failures | 

## IterableCommerceItem
An item that was added to, removed from, updated in the cart, or purchased. Create an array of IterableCommerceItem when including in the `updateCart` and `trackPurchase` methods.

| Name                      | Type                                                                                                                                                                                                                     | Description                                                           | Example |
|---------------------------|--------------------------------|------------------------------------------------------------------|----------------|
|`id`|`String`| The unique item id | `abc123`|
|`name`|`String`| The item name | `Shirt`|
|`price`|`double`| The item price | `9.99`|
|`int`|`quantity`| The item quantity | `1`|
|`sku`|`String?`| (Optional) The item sku | `abc123-xyz456`|
|`description`|`String?`| (Optional) The description of the item | `A really cool shirt`|
|`url`|`String?`| (Optional) The url to the sepecific item | `https://iterableshop.com/shirts/red-shirt`|
|`imageUrl`|`String?`| (Optional) The url to the item image | `https://iterableshop.com/assets/shirts/red-shirt.jpg`|
|`categories`|`List<String>?`| (Optional) The associated categories for the item | `["clothes", "hot items", "sale"]`|
|`dataFields`|`Map<String, Object>?`| (Optional) Any additional metadata about the item | `{"eligible_rewards": 1000}`|

Example:

```
List<IterableCommerceItem> items = [
      IterableCommerceItem("abc123", "Shirt", 9.99, 1,
          sku: "abc123-xyz456",
          categories: ["sale", "blouses"],
          dataFields: {"eligible_rewards": 1000}),
      IterableCommerceItem("def456", "Shoes", 19.99, 2,
          sku: "def456-tuv789",
          categories: ["hot items", "women's"],
          dataFields: {"promo": "summer2022"})
    ];
```

## IterableAttributionInfo

The attribution information about the campaign that prompted the user to click the link. The SDK stores this information for retrieval using the [`getAttributionInfo`](#getAttributionInfo) method. Once retrieved, you can attach this information to events and purchases. To manually set this information, call the [`setAttributionInfo`](#setAttributionInfo) method.

| Name                      | Type | Example |
|---------------------------|--------------------------------|------------------------------------------------------------------|
|`campaignId`| `int` | `12345` |
|`templateId`| `int` | `67890` |
|`messageId`| `String` | `gKWPW6mrNflnVnU7RbKwSau7uq09GZXc2x0rwCmla99kGJ ` |


## IterableInAppMessage

A class that represents Iterable in-app message.

| Name                      | Type |Description | Example |
|---------------------------|--------------------------------|------------------------------------------------------------------|---------------|
|`messageId`| `String` | Unique id for the message | `gKWPW6mrNflnVnU7RbKwSau7uq09GZXc2x0rwCmla99kGJ ` |
|`campaignId`| `int` | Associated campaign id | `67890` |
|`content`| [`IterableHtmlInAppContent`](#iterablehtmlinappcontent) | The applicable content of the in-app message | See example below |
|`trigger`| [`IterableInAppTrigger`](#iterableinapptrigger) | The trigger type of the in-app message | See example below |
|`saveToInbox`| `int` | Indicates whether or not to save in a messaging inbox |`false` |
|`read`| `int` | Indicates whether or not the message has already been seen | `false` |
|`priorityLevel`| `int` | Display priority level that was configured within the campaign | `300` |
|`createdAt`| `String?` | The date and time the in-app message was sent | `2022-01-16T21:08:11.199Z ` |
|`expiresAt`| `String?` | The date and time the in-app message expires | `2022-04-16T21:08:11.199Z ` |
|`inboxMetadata`| `IterableInboxMetadata? ` | The metadata associated with the messaging inbox (if applicable_ | `{"title":"Discount Activated!","subtitle":"You just received a 10% discount","icon":"https://someiconurl.com/icon.png"} ` |
|`customPayload`| `Map<String, Object>? ` | The custom JSON payload that was attached to the message upon creation | `{"messageType":"promotional","discount":"10%"}` |

Example Return Value:

```
{
    "campaignId": 2342343,
    "content":
    {
        "edgeInsets":
        {
            "bottom": 0.0,
            "left": 0.0,
            "right": 0.0,
            "top": 0.0
        },
        "html": "...",
        "type": 0
    },
    "createdAt": "2022-01-16T21:08:11.199Z",
    "customPayload":
    {
        "customCellName": "AdvancedInboxCell",
        "discount": "10%",
        "messageSection": 0,
        "messageType": "promotional",
        "shouldSkip": true
    },
    "expiresAt": "2022-04-16T21:08:11.199Z",
    "inboxMetadata":
    {
        "icon": "https://someurl.com",
        "subtitle": "test subtitle",
        "title": "test title"
    },
    "messageId": "gKWPW6mrNflnVnU7RbKwSau7uq09GZXc2x0rwCmla99kGJ",
    "priorityLevel": 200.5,
    "read": true,
    "saveToInbox": true,
    "trigger":
    {
        "type": 0
    }
}
```

## IterableHtmlInAppContent

The display content of the in-app message.

|Name|Type|Description|Example|
|-------------|------------|----------|---------|
|`type`| `int` | The type of in-app message (currently this is always 0 to represent html, but may support other display options in the future| `0`|
|`html`| `String` | HTML content of the message | `<!DOCTYPE html><head>...</head><body>...</body></html>`
|`edgeInsents`| [`IterableEdgeInsets`](#iterableedgeinsets) | Padding/insets for the in-app display modal |`{"top":10.0,"left":10.0,"bottom":0.0,"right":0.0}`|

Example Return Value:

```
{
    "edgeInsets":
    {
        "bottom": 0.0,
        "left": 10.0,
        "right": 0.0,
        "top": 10.0
    },
    "html": "<!DOCTYPE html><head>...</head><body>...</body></html>",
    "type": 0
}
```

## IterableInAppTrigger

The trigger type for the in-app message.

|Name|Type|Example|
|-------------|------------|----------|
| `type` | `int` | `0` |

The following trigger types are available:

| Value                     | Description                                                                                                                                                                                                                      
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `0` | `immediate` |
| `1` | `event` |
| `2` | `never` |


## IterableEdgeInsets

Padding/insets for the in-app display modal.

|Name|Type|Example|
|-------------|------------|----------|
| `top` | `double` | `10.0` |
| `left` | `double` | `10.0` |
| `bottom` | `double` | `0.0` |
| `right` | `double` | `0.0` |

## IterableInAppLocation

An enum that describes the various places that an in-app message can exist.

The following location values are available:

| Value                     | Description                                                                                                                                                                                                                      
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `IterableInAppLocation.inApp` | If location was a standard in-app modal |
| `IterableInAppLocation.inbox` | If location was within a messaging inbox |

## IterableInAppCloseSource

An enum that describes the various ways in which an in-app message might have been closed.

The following close source values are available:

| Value                     | Description                                                                                                                                                                                                                      
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `IterableInAppCloseSource.back` | If the user clicks a back button on the in-app |
| `IterableInAppCloseSource.link` | If the user clicks a link within an in-app |
| `IterableInAppCloseSource.unknown` | All others |

## IterableInAppDeleteSource

An enum that describes the various ways in which an in-app message might have been deleted (most applicable for an inbox).

The following delete source values are available:

| Value                     | Description                                                                                                                                                                                                                      
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `IterableInAppDeleteSource.inboxSwipe` | Swiping to delete within an inbox view |
| `IterableInAppDeleteSource.deleteButton` | Using a delete button within an inbox view |
| `IterableInAppDeleteSource.unknown` | All others |

## IterableInAppShowResponse

An enum that describes two display options for an incoming in-app message.

The following show response values are available:

| Value                     | Description                                                                                                                                                                                                                      
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `IterableInAppShowResponse.show` | To show the message immediately |
| `IterableInAppShowResponse.skip` | To skip displaying the message |

# Usage

## initialize 

API:

```
Future<bool> initialize(String apiKey, IterableConfig config)
```

Example:

```
final config = IterableConfig(inAppDisplayInterval: 1.0, logLevel: IterableLogLevel.info);

IterableAPI.initialize('YOUR_API_KEY', config).then((success) => {
	if (success) {
		debugPrint('Iterable Initialized'),
		IterableAPI.setEmail("email@example.com")
   }
});
```

## setEmail

API:

```
setEmail(String? email)
```

Example:

```
IterableAPI.setEmail("email@example.com");
```

## setUserId 

API:

```
setUserId(String? userId)
```

Example:

```
IterableAPI.setUserId("user123123");
```

## setEmailAndUserId 

API:

```
Future<String> setEmailAndUserId(String email, String userId)
```

Example:

```
IterableAPI.setEmailAndUserId("email@example.com", "user123123")
           .then((response) => debugPrint(jsonEncode(response)));
``` 

## getEmail 

API:

```
Future<String> getEmail()
```

Example:

```
IterableAPI.getEmail()
           .then((email) => debugPrint('Current Email: $email'));
```

## getUserId 

API:

```
Future<String> getUserId()
```

Example:

```
IterableAPI.getUserId()
           .then((userId) => debugPrint('Current User Id: $userId'));
```

## updateEmail 

API:

```
Future<String> updateEmail(String email)
```

Example:

```
IterableAPI.updateEmail("email@example.com")
           .then((response) => debugPrint(jsonEncode(response));
```

## updateUser 


API:

```
Future<String> updateUser(Map<String, Object> dataFields, bool? mergeNestedObjects)
```

Example:

```
IterableAPI.updateUser({'favoriteColor': 'blue'}, false)
           .then((response) => debugPrint(jsonEncode(response)));
```

## updateSubscriptions 

API:

```
updateSubscriptions({
	List<int>? emailListIds,
	List<int>? unsubscribedChannelIds,
	List<int>? unsubscribedMessageTypeIds,
	List<int>? subscribedMessageTypeIds,
	int? campaignId,
	int? templateId
})
```

Example:

```
IterableAPI.updateSubscriptions(
	emailListIds: [1234],
	subscribedMessageTypeIds: [12345],
	unsubscribedChannelIds: [67890],
	unsubscribedMessageTypeIds: [78901]
);
```

## trackEvent 

API:

```
trackEvent(String name, Map<String, Object>? dataFields)
```

Example:

```
IterableAPI.trackEvent('Added Promo', {'promoCode': 'abc123'});
```

## updateCart 

API:

```
updateCart(List<IterableCommerceItem> items)
```

Example:

```
List<IterableCommerceItem> items = [
      IterableCommerceItem("abc123", "Shirt", 9.99, 1,
          sku: "abc123-xyz456",
          categories: ["sale", "blouses"],
          dataFields: {"eligible_rewards": 1000}),
      IterableCommerceItem("def456", "Shoes", 19.99, 2,
          sku: "def456-tuv789",
          categories: ["hot items", "women's"],
          dataFields: {"promo": "summer2022"})
];

IterableAPI.updateCart(items);
```

## trackPurchase 

API:

```
trackPurchase(double total, List<IterableCommerceItem> items, Map<String, Object>? dataFields)
```

Example:

```
List<IterableCommerceItem> items = [
      IterableCommerceItem("def456", "Shoes", 19.99, 2,
          sku: "def456-tuv789",
          categories: ["hot items", "women's"],
          dataFields: {"promo": "summer2022"})
];

IterableAPI.trackPurchase(19.98, items, {'rewards': 100});
```


## trackPushOpenWithCampaignId 

API:

```
trackPushOpenWithCampaignId(
	int campaignId,
	int templateId,
	String messageId,
	bool appAlreadyRunning,
	Map<String, Object>? dataFields
)
```

Example:

```
IterableAPI.trackPushOpenWithCampaignId(
	123456,
	789012,
	"gKWPW6mrNflnVnU7RbKwSau7uq09GZXc2x0rwCmla99kGJ",
	false,
	{'promo': 'abc123'}
);
```

## getLastPushPayload 

API:

```
Future<dynamic> getLastPushPayload()
```

Example:

```
IterableAPI.getLastPushPayload().then((payload) => debugPrint('Last Push Payload: $payload');
```

## disableDeviceForCurrentUser 

API:

```
disableDeviceForCurrentUser()
```

Example:

```
IterableAPI.disableDeviceForCurrentUser();
```

## trackInAppOpen 

API:

```
trackInAppOpen(IterableInAppMessage message, IterableInAppLocation location)
```

Example:

```
IterableAPI.trackInAppOpen(message, IterableInAppLocation.inApp);
```

## trackInAppClick 

API:

```
trackInAppClick(IterableInAppMessage message, IterableInAppLocation location, String clickedUrl)
```

Example:

```
IterableAPI.trackInAppClick(
	message,
	IterableInAppLocation.inApp,
	"https://example.com/deeplinkurl"
);
```

## trackInAppClose 

API:

```
trackInAppClose(
	IterableInAppMessage message,
	IterableInAppLocation location,
	IterableInAppCloseSource source,
	String? clickedUrl
)
```

Example:

```
IterableAPI.trackInAppClose(
	message,
	IterableInAppLocation.inApp,
	IterableInAppCloseSource.link,
	"https:/example.com/deeplink-close"
);
``` 

## inAppConsume 


API:

```
inAppConsume(
	IterableInAppMessage message,
	IterableInAppLocation location,
	IterableInAppDeleteSource source
)
```

Example:

```
IterableAPI.inAppConsume(
	message, 
	IterableInAppLocation.inbox,
	IterableInAppDeleteSource.inboxSwipe
);
``` 

## getMessages 

API:

```
Future<List<IterableInAppMessage>> getMessages()
```

Example:

```
IterableAPI
	.inAppManager
   		.getMessages()
			.then((messages) => {
				messages
					.asMap()
					.forEach((index, message) => {
            			developer.log(jsonEncode((message.toJson())));
           		});
    		});
``` 

## getAttributionInfo 

API:

```
Future<IterableAttributionInfo?> getAttributionInfo()
```

Example:

```
IterableAPI.getAttributionInfo()
           .then((attrInfo) => debugPrint(jsonEncode(attrInfo?.toJson())))
``` 

## setAttributionInfo 

API:

```
setAttributionInfo(IterableAttributionInfo attributionInfo)
```

Example:

```
IterableAPI.setAttributionInfo(
		IterableAttributionInfo(
      		123456, 789012, "gKWPW6mrNflnVnU7RbKwSau7uq09GZXc2x0rwCmla99kGJ")
      	)
``` 

## showMessage

API:

```
Future<String?> showMessage(IterableInAppMessage message, bool consume)
```

Example:

```
IterableAPI.inAppManager.showMessage(message, true)
``` 

## removeMessage

API:

```
removeMessage(
	IterableInAppMessage message,
	IterableInAppLocation location,
	IterableInAppDeleteSource source
)
```

Example:

```
IterableAPI.inAppManager.removeMessage(
	message,
	IterableInAppLocation.inApp,
	IterableInAppDeleteSource.deleteButton
)
``` 

## setReadForMessage

API:

```
setReadForMessage(IterableInAppMessage message, bool read)
```

Example:

```
IterableAPI.inAppManager.setReadForMessage(message, true)
``` 

## getHtmlContentForMessage

API:

```
Future<IterableHtmlInAppContent> getHtmlContentForMessage(IterableInAppMessage message)
```

Example:

```
IterableAPI
	.inAppManager
	.getHtmlContentForMessage(message)
	.then((content) =>
		debugPrint(jsonEncode((content.toJson()))))
```

## setAutoDisplayPaused


API:

```
setAutoDisplayPaused(bool paused)
```

Example:

```
IterableAPI.inAppManager.setAutoDisplayPaused(true)
``` 


# FAQ

TODO

# Contributing

Looking to contribute? Please see the [contributing instructions here](./CONTRIBUTING.md) for more
details.

# License

This SDK is released under the MIT License. See [LICENSE](./LICENSE.md) for more information.