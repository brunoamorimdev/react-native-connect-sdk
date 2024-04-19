

#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNConnectSdkSpec.h"

@interface ConnectionManager : RCTEventEmitter <NativeConnectionManagerSpec>
#else
#import <React/RCTBridgeModule.h>

@interface ConnectionManager : RCTEventEmitter <RCTBridgeModule>
#endif

@end
