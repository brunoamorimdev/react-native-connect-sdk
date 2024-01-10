#import "ConnectSdk.h"
#import "ConnectSDK/ConnectSDK.h"
#import "React/RCTViewManager.h"
#import "CoreLocation/CoreLocation.h"

@interface JSDeviceState : NSObject

@property (nonatomic, strong) id device;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *callbackId;
@property (nonatomic, strong) RCTResponseSenderBlock success;
@property (nonatomic, strong) RCTResponseSenderBlock error;
@property (nonatomic, strong) JSCommandDispatcher* dispatcher;

@end

@implementation JSDeviceState {
}

+ (JSDeviceState *) stateFromDevice:(ConnectableDevice*)device
{
    JSDeviceState *state = [JSDeviceState new];
    state.device = device;
    state.deviceId = [device id];
    state.callbackId = nil;
    state.success = nil;
    state.error = nil;
    
    return state;
}

@end

@interface ConnectSdk () <DevicePickerDelegate, DiscoveryManagerDelegate, ConnectableDeviceDelegate>
@property DiscoveryManager *discoveryManager;
@property ConnectableDevice *connectableDevice;
@end

@implementation ConnectSdk
RCT_EXPORT_MODULE(ConnectSDK)


@synthesize discoveryManager = _discoveryManager;
@synthesize connectableDevice = _connectableDevice;


- (void)startDiscovery:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    _discoveryManager.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_discoveryManager registerDefaultServices];
        [self->_discoveryManager startDiscovery];
    });
}

- (void)stopDiscovery:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSLog(@"Stopping Discovery");

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_discoveryManager stopDiscovery];
    });
}


- (void) setupDiscovery:(NSDictionary *)config :(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject
{
    if (!_discoveryManager) {
            _discoveryManager = [DiscoveryManager sharedManager];
        }
    
    if (config) {
            NSString* pairingLevel = config[@"pairingLevel"];
            
            if (pairingLevel != nil) {
                if ([pairingLevel isEqualToString:@""] || [pairingLevel isEqualToString:@"off"]) {
                    [_discoveryManager setPairingLevel:DeviceServicePairingLevelOff];
                } else if ([pairingLevel isEqualToString:@"on"]) {
                    [_discoveryManager setPairingLevel:DeviceServicePairingLevelOn];
                }
            }
            
            
            NSArray* filterObjs = config[@"capabilityFilters"];
            if (filterObjs) {
                NSMutableArray* capFilters = [NSMutableArray array];
                
                for (NSArray* filterArray in filterObjs) {
                    CapabilityFilter* capFilter = [CapabilityFilter filterWithCapabilities:filterArray];
                    [capFilters addObject:capFilter];
                }
                
                [_discoveryManager setCapabilityFilters:capFilters];
            }
        }
}


- (void)openConnectableDevicesPicker:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject 
{
    @try {
        DevicePicker *picker = [_discoveryManager devicePicker];
        picker.delegate = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *view = [[[RCTSharedApplication() delegate] window] rootViewController];
            
            [picker showPicker:view];
        });
        
        resolve(@0);
    } @catch (NSException *exception) {
        reject(@"[Connectable Devices Picker]",[NSString stringWithFormat:@"[Exception %@] - [%@]", [exception name], [exception reason]], nil);
    }
    
}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeConnectSdkSpecJSI>(params);
}
#endif

- (void) devicePicker:(DevicePicker *)picker didSelectDevice:(ConnectableDevice *)device;
{
        if (self.automaticPairingTypeNumber) {
            [self setPairingTypeNumber:self.automaticPairingTypeNumber
                              toDevice:device];
        }
        
        device.delegate = self;
        [device connect];
        NSDictionary* dict = [self deviceAsDict:device];
}

- (void) devicePicker:(DevicePicker *)picker didCancelWithError:(NSError*)error
{
        NSString* errorString = [error localizedDescription];
}

- (void)connectableDeviceDisconnected:(ConnectableDevice *)device withError:(NSError *)error { 
    <#code#>
}

- (void)connectableDeviceReady:(ConnectableDevice *)device { 
    <#code#>
}

- (JSDeviceState*) getOrCreateDeviceState:(ConnectableDevice*)device
{
    @synchronized(self) {
        JSDeviceState *deviceState = (JSDeviceState*) [_deviceStateByDevice objectForKey:device];
        if (deviceState == nil) {
            deviceState = [JSDeviceState stateFromDevice:device];
            [_deviceStateByDevice setObject:deviceState forKey:device];
            [_deviceStateById setObject:deviceState forKey:[deviceState deviceId]];
        }
        return deviceState;
    }
}

- (NSDictionary*) deviceAsDict:(ConnectableDevice*)device
{
    NSMutableArray* services = [NSMutableArray array];
    
    for (DeviceService* service in device.services) {
        NSDictionary* serviceDict = @{
            @"name": service.serviceName
        };
        
        [services addObject:serviceDict];
    }
    
    return @{
        @"deviceId": [[self getOrCreateDeviceState:device] deviceId],
        @"ipAddress": orNull(device.address),
        @"friendlyName": orNull(device.friendlyName),
        @"modelName": orNull(device.modelName),
        @"modelNumber": orNull(device.modelNumber),
        @"capabilities": [device capabilities],
        @"services": services
    };
}

@end
