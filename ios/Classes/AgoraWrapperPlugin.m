#import "AgoraWrapperPlugin.h"
#if __has_include(<agora_wrapper/agora_wrapper-Swift.h>)
#import <agora_wrapper/agora_wrapper-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "agora_wrapper-Swift.h"
#endif

@implementation AgoraWrapperPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftAgoraWrapperPlugin registerWithRegistrar:registrar];
}
@end
