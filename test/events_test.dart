import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iterable/iterable_api.dart';
import 'package:iterable/common.dart';
import 'package:iterable/inapp/inapp_common.dart';

void main() {
  List<MethodCall> log = <MethodCall>[];
  const MethodChannel channel = MethodChannel('iterable');

  TestWidgetsFlutterBinding.ensureInitialized();

  IterableInAppMessage mockMessage = IterableInAppMessage(
      'mock-id',
      123,
      IterableHtmlInAppContent(IterableEdgeInsets(0, 0, 0, 0), ''),
      IterableInAppTrigger(type: IterableInAppTriggerType.never),
      false,
      false,
      100);

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    log = <MethodCall>[];
  });

  test('should call trackEvent correctly with the correct arguments', () async {
    final config = IterableConfig();

    await IterableAPI.trackEvent('my-event', {'foo': 'bar'});

    expect(
        log.single,
        isMethodCall(
          'trackEvent',
          arguments: <String, dynamic>{
            'eventName': 'my-event',
            'dataFields': {'foo': 'bar'}
          },
        ));
  });

  test('should call trackInAppOpen correctly with the correct arguments',
      () async {
    final config = IterableConfig();

    await IterableAPI.trackInAppOpen(mockMessage, IterableInAppLocation.inApp);

    expect(
        log.single,
        isMethodCall(
          'trackInAppOpen',
          arguments: <String, dynamic>{'messageId': 'mock-id', 'location': 0},
        ));
  });

  test('should call trackInAppClose correctly with the correct arguments',
      () async {
    final config = IterableConfig();

    await IterableAPI.trackInAppClose(mockMessage, IterableInAppLocation.inApp,
        IterableInAppCloseSource.back, 'https://google.com');

    expect(
        log.single,
        isMethodCall(
          'trackInAppClose',
          arguments: <String, dynamic>{
            'messageId': 'mock-id',
            'location': 0,
            'source': 0,
            'clickedUrl': 'https://google.com'
          },
        ));
  });

  test('should call trackInAppClick correctly with the correct arguments',
      () async {
    final config = IterableConfig();

    await IterableAPI.trackInAppClick(
        mockMessage, IterableInAppLocation.inApp, 'https://google.com');

    expect(
        log.single,
        isMethodCall(
          'trackInAppClick',
          arguments: <String, dynamic>{
            'messageId': 'mock-id',
            'location': 0,
            'clickedUrl': 'https://google.com'
          },
        ));
  });
}
