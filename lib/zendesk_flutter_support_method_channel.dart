import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'zendesk_flutter_support_platform_interface.dart';

/// An implementation of [ZendeskFlutterSupportPlatform] that uses method channels.
class MethodChannelZendeskFlutterSupport extends ZendeskFlutterSupportPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zendesk_flutter_support');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
