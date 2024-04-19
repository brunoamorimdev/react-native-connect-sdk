//
//  JSDevice.h
//  react-native-connect-sdk
//
//  Created by Bruno Amorim on 19/04/24.
//
#import <ConnectSDK/ConnectableDevice.h>

@interface JSDevice : NSObject
- (NSDictionary *) buildWith:(ConnectableDevice *)device;
@end
