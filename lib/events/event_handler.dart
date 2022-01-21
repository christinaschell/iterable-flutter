import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iterable/inapp/inapp_common.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'event_emitter.dart';
import 'dart:async';
import 'dart:convert';
import '../common.dart';

class IterableEventHandler {
  static EventEmitter emitter = EventEmitter();
  static final Map<String, Function> _listeners = {};
  late MethodChannel channel;
  Timer? timer;

  IterableEventHandler({required this.channel});

  void setEventHandler<T>(name, callback) => {
        if (Utilities.cast(callback) != null)
          {_listeners[name] = callback, _handle(name)}
      };

  _handle(String name) {
    channel.setMethodCallHandler(_methodCallHandler);
    emitter.on(name, {}, (ev, context) {
      switch (name) {
        case EventListenerNames.inAppHandler:
          var encodedData = jsonEncode(ev.eventData);
          var eventDataMap = jsonDecode(encodedData) as Map;
          var message = IterableInAppMessage.from(jsonEncode(eventDataMap));
          IterableInAppHandler callback =
              _listeners[EventListenerNames.inAppHandler]
                  as IterableInAppHandler;
          var response = callback(message);
          _setInAppShowResponse(response);
          break;
        case EventListenerNames.urlHandler:
          dynamic encodedData = jsonEncode(ev.eventData);
          Map eventDataMap = jsonDecode(encodedData) as Map;
          String url = eventDataMap["url"];
          IterableActionContext context =
              IterableActionContext.from(eventDataMap["context"]);
          IterableUrlHandler callback =
              _listeners[EventListenerNames.urlHandler] as IterableUrlHandler;
          _wakeApp();
          if (Platform.isAndroid) {
            // Give enough time for Activity to wake up.
            timer = Timer(const Duration(seconds: 1),
                () => _callUrlHandler(url, context, callback));
          } else {
            _callUrlHandler(url, context, callback);
          }
          break;
        case EventListenerNames.customActionHandler:
          dynamic encodedData = jsonEncode(ev.eventData);
          Map eventDataMap = jsonDecode(encodedData) as Map;
          IterableAction action = IterableAction.from(eventDataMap["action"]);
          IterableActionContext context =
              IterableActionContext.from(eventDataMap["context"]);
          IterableCustomActionHandler callback =
              _listeners[EventListenerNames.customActionHandler]
                  as IterableCustomActionHandler;
          callback(action, context);
          break;
        case EventListenerNames.authHandler:
          IterableAuthHandler callback =
              _listeners[EventListenerNames.authHandler] as IterableAuthHandler;
          callback().then((token) => _setAuthToken(token));
          break;
        default:
          break;
      }
    });
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method.toString() == 'callListener') {
      emitter.emit(
          call.arguments[EventListenerNames.name], null, call.arguments);
    }
  }

  _setAuthToken(String token) {
    channel.invokeMethod('setAuthToken', {'token': token});
  }

  _setInAppShowResponse(IterableInAppShowResponse response) {
    channel.invokeMethod(
        'setInAppShowResponse', {'showResponse': response.toInt()});
  }

  _callUrlHandler(
      String url, IterableActionContext context, Function callback) {
    bool handledResult = callback(url, context);
    if (handledResult == false) {
      launcher.canLaunch(url).then((canOpen) => {
            if (canOpen)
              {launcher.launch(url)}
            else
              {debugPrint("Could not open Url.")},
            timer?.cancel()
          });
    }
  }

  /// Wakes the app in Android
  _wakeApp() {
    if (Platform.isAndroid) {
      channel.invokeMethod('wakeApp');
    }
  }
}
