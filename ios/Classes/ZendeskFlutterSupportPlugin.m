#import "ZendeskFlutterSupportPlugin.h"
#if __has_include(<zendesk_flutter_support/zendesk_flutter_support-Swift.h>)
#import <zendesk_flutter_support/zendesk_flutter_support-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "zendesk_flutter_support-Swift.h"
#endif

@implementation ZendeskFlutterSupportPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZendeskFlutterSupportPlugin registerWithRegistrar:registrar];
}
@end
