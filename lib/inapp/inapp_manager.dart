import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'inapp_common.dart';

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
  /// Only used for mobile inbox when available
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
