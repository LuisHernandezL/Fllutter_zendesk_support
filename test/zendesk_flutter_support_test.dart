import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_flutter_support/zendesk_flutter_support.dart';
import 'package:zendesk_flutter_support/zendesk_flutter_support_platform_interface.dart';
import 'package:zendesk_flutter_support/zendesk_flutter_support_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockZendeskFlutterSupportPlatform
    with MockPlatformInterfaceMixin
    implements ZendeskFlutterSupportPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ZendeskFlutterSupportPlatform initialPlatform = ZendeskFlutterSupportPlatform.instance;

  test('$MethodChannelZendeskFlutterSupport is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZendeskFlutterSupport>());
  });

  test('getPlatformVersion', () async {
    ZendeskFlutterSupport zendeskFlutterSupportPlugin = ZendeskFlutterSupport();
    MockZendeskFlutterSupportPlatform fakePlatform = MockZendeskFlutterSupportPlatform();
    ZendeskFlutterSupportPlatform.instance = fakePlatform;

    expect(await zendeskFlutterSupportPlugin.getPlatformVersion(), '42');
  });
}
