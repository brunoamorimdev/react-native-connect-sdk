
#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNConnectSdkSpec.h"

@interface ConnectSdk : RCTEventEmitter <NativeConnectSdkSpec>
#else
#import <React/RCTBridgeModule.h>


@interface ConnectSdk : RCTEventEmitter <RCTBridgeModule>
#endif

@end
