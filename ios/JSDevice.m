//
//  JSDevice.m
//  react-native-connect-sdk
//
//  Created by Bruno Amorim on 19/04/24.
//
#import "JSDevice.h"

@implementation JSDevice
- (NSDictionary *)buildWith:(ConnectableDevice *)device {
    return @{
        @"ipAddress": orNull(device.address),
        @"friendlyName": orNull(device.friendlyName),
    };
}

#pragma mark Helpers

static id orNull (id obj)
{
    return obj ? obj : [NSNull null];
}
@end
