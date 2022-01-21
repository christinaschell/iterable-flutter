#import "IterablePlugin.h"
#if __has_include(<iterable/iterable-Swift.h>)
#import <iterable/iterable-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "iterable-Swift.h"
#endif

@implementation IterablePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIterablePlugin registerWithRegistrar:registrar];
}
@end
