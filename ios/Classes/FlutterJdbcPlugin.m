#import "FlutterJdbcPlugin.h"
#if __has_include(<flutter_jdbc_plugin/flutter_jdbc_plugin-Swift.h>)
#import <flutter_jdbc_plugin/flutter_jdbc_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_jdbc_plugin-Swift.h"
#endif

@implementation FlutterJdbcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterJdbcPlugin registerWithRegistrar:registrar];
}
@end
