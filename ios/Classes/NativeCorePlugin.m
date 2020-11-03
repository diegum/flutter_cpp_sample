#import "NativeCorePlugin.h"
#if __has_include(<native_core/native_core-Swift.h>)
#import <native_core/native_core-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_core-Swift.h"
#endif

@implementation NativeCorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeCorePlugin registerWithRegistrar:registrar];
}
@end
