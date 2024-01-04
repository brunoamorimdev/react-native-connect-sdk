#import "ConnectSdk.h"
#import "ConnectSDK/ConnectSDK.h"
#import "React/RCTViewManager.h"
#import "CoreLocation/CoreLocation.h"

@interface ConnectSdk ()
@property DiscoveryManager *discoveryManager;
@property ConnectableDevice *connectableDevice;
@end

@implementation ConnectSdk
RCT_EXPORT_MODULE(ConnectSDK)


@synthesize discoveryManager = _discoveryManager;
@synthesize connectableDevice = _connectableDevice;


+ (BOOL)requiresMainQueueSetup
{
    return YES;
}


- (void) setupDiscoveryManager
{
    
    NSLog(@"Setup Discovery Manger");
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        
        // Request authorization for location services
        [locationManager requestWhenInUseAuthorization]; // or requestAlwaysAuthorization
        
        // Start updating location
        [locationManager startUpdatingLocation];
        
        if (!_discoveryManager) {
            NSLog(@"Discovery Manger Initiliazing");
            _discoveryManager = [DiscoveryManager sharedManager];
        }
    }
}


- (instancetype)init
{
    NSLog(@"Initializer ConnectSDK");
    self = [super init];
    [self setupDiscoveryManager];
    return self;
}


- (void)openConnectableDevicesPicker:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    @try {
        NSLog(@"Opening Connectable Devices Picker");
        
        DevicePicker *picker = [_discoveryManager devicePicker];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *view = [[[RCTSharedApplication() delegate] window] rootViewController];
            
            [picker showPicker:view];
        });
        
        resolve(@0);
    } @catch (NSException *exception) {
        reject(@"[Connectable Devices Picker]",[NSString stringWithFormat:@"[Exception %@] - [%@]", [exception name], [exception reason]], nil);
    }
    
}

- (void)startDiscovery:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSLog(@"Starting Discovery");

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


// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeConnectSdkSpecJSI>(params);
}
#endif

@end
