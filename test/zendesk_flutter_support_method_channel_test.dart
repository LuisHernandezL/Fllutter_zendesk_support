import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_flutter_support/zendesk_flutter_support_method_channel.dart';

void main() {
  MethodChannelZendeskFlutterSupport platform = MethodChannelZendeskFlutterSupport();
  const MethodChannel channel = MethodChannel('zendesk_flutter_support');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
