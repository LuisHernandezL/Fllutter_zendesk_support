import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zendesk_flutter_support_method_channel.dart';

abstract class ZendeskFlutterSupportPlatform extends PlatformInterface {
  /// Constructs a ZendeskFlutterSupportPlatform.
  ZendeskFlutterSupportPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZendeskFlutterSupportPlatform _instance = MethodChannelZendeskFlutterSupport();

  /// The default instance of [ZendeskFlutterSupportPlatform] to use.
  ///
  /// Defaults to [MethodChannelZendeskFlutterSupport].
  static ZendeskFlutterSupportPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZendeskFlutterSupportPlatform] when
  /// they register themselves.
  static set instance(ZendeskFlutterSupportPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
