
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNConnectSdkSpec.h"

@interface ConnectSdk : NSObject <NativeConnectSdkSpec>
#else
#import <React/RCTBridgeModule.h>

@interface ConnectSdk : NSObject <RCTBridgeModule>
#endif

@end
