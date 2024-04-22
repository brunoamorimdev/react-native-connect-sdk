//
//  ConnectionManager.m
//  TvControl
//
//  Created by Bruno Amorim on 17/04/24.
//

#import "ConnectionManager.h"
#import <CoreLocation/CoreLocation.h>
#import <ConnectSDK/ConnectSDK.h>


NSDictionary* buildJSDevice(ConnectableDevice *device){
    return @{
      @"friendlyName": device.friendlyName,
      @"ipAddress": device.address
    };
}

@interface ConnectionManager () <CLLocationManagerDelegate,
DiscoveryManagerDelegate, ConnectableDeviceDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) DiscoveryManager *discoveryManager;
@property (nonatomic, strong) NSMutableArray<ConnectableDevice *> *allDevices;
@property (nonatomic, strong) ConnectableDevice *currentDevice;
@end

@implementation ConnectionManager
{
  bool hasListeners;
}

RCT_EXPORT_MODULE()


- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.allDevices = [[NSMutableArray alloc] init];
    }
    
    [self startObserving];
    
    return self;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}



#pragma mark - RCTEventEmmiter

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"didFindDevice",
             @"didLoseDevice",
             @"didFailWithError",
             @"didUpdateDevice"];
}

#pragma mark - ConnectionManager

RCT_EXPORT_METHOD(connect:(NSString *)ipAddress 
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

    ConnectableDevice *device = self
        .discoveryManager
        .compatibleDevices[ipAddress];
    
    if (!device) {
        reject(@"connectable_device_not_found",
               @"connectable device not found", nil);
    }
    
    self.currentDevice = device;
    self.currentDevice.delegate = self;
    [self.currentDevice connect];
    
    resolve(ipAddress);
}

RCT_EXPORT_METHOD(startDiscovery:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    if ([self isAuthorizedToUseLocation]) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self locationManager:self
         .locationManager didChangeAuthorizationStatus:[self
             .locationManager authorizationStatus]];
    }
}

RCT_EXPORT_METHOD(stopDiscovery:(RCTPromiseResolveBlock)resolve 
                  reject:(RCTPromiseRejectBlock)reject){
    [self.discoveryManager stopDiscovery];
    [self.locationManager stopUpdatingLocation];
}

RCT_EXPORT_METHOD(getAllDevices:(RCTPromiseResolveBlock)resolve 
                  reject:(RCTPromiseRejectBlock)reject){
    // Create a mutable array to store the JS representation of devices.
    NSMutableArray *devicesJSRepresentation = [NSMutableArray array];
    
    // Iterate over all devices and build their JS representation.
    for (ConnectableDevice *device in [[self.discoveryManager allDevices] allValues]) {
        NSDictionary *jsDevice = buildJSDevice(device);
        [devicesJSRepresentation addObject:jsDevice];
    }
    
    // Resolve the promise with the JS representation of all devices.
    resolve(devicesJSRepresentation);
}


#pragma mark - CLLocationManagerDelegate

- (BOOL)isAuthorizedToUseLocation{
    return [self.locationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [self.locationManager authorizationStatus] == kCLAuthorizationStatusDenied || [self.locationManager authorizationStatus] == kCLAuthorizationStatusRestricted;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
            if (!self.discoveryManager){
                self.discoveryManager = [DiscoveryManager sharedManager];
            }
            self.discoveryManager.delegate = self;
            [self.discoveryManager startDiscovery];
        } else {
            // Handle not authorized status
            NSLog(@"Location Authorization Denied");
        }
    });
   
}

#pragma mark - DiscoveryManagerDelegate


- (void)discoveryManager:(DiscoveryManager *)manager 
           didFindDevice:(ConnectableDevice *)device {
    dispatch_async(dispatch_get_main_queue(), ^{
           NSLog(@"Found device: %@", device.friendlyName);
           [self.allDevices addObject:device];
           if (self->hasListeners) {
               [self addListener:@"didFindDevice"]; // Potentially adjust `addListener` usage if necessary
               [self sendEventWithName:@"didFindDevice" body:buildJSDevice(device)];
           }
       });
}

- (void)discoveryManager:(DiscoveryManager *)manager 
           didLoseDevice:(ConnectableDevice *)device {
    NSLog(@"Lost device: %@", device.friendlyName);
    [self.allDevices removeObject:device];
    if (hasListeners){
        // Without adding manually
        // it returns a warning that the event is emmited but no listener
        [self addListener:@"didLoseDevice"];
        [self sendEventWithName:@"didLoseDevice" body:buildJSDevice(device)];
    }
}

- (void)discoveryManager:(DiscoveryManager *)manager 
        didFailWithError:(NSError *)error {
    NSLog(@"Discovery failed with error: %@", error);
    if (hasListeners){
        // Without adding manually
        // it returns a warning that the event is emmited but no listener
        [self addListener:@"didFailWithError"];
        [self sendEventWithName:@"didFailWithError" body:error.description];
    }
}

- (void)discoveryManager:(DiscoveryManager *)manager
         didUpdateDevice:(ConnectableDevice *)device {
    NSLog(@"Device updated: %@", device.friendlyName);
    
    NSInteger existingIndex = 
    [self.allDevices
     indexOfObjectPassingTest:^BOOL(ConnectableDevice* _Nonnull obj,
                                    NSUInteger idx,
                                    BOOL * _Nonnull stop) {
        return [obj.id isEqualToString:device.id];
    }];
    
    if (existingIndex != NSNotFound) {
        [self.allDevices replaceObjectAtIndex:existingIndex withObject:device];
    } else {
        [self.allDevices addObject:device];
    }
    
    if (hasListeners){
        // Without adding manually
        // it returns a warning that the event is emmited but no listener
        [self addListener:@"didUpdateDevice"];
        [self sendEventWithName:@"didUpdateDevice" body:buildJSDevice(device)];
    }
}

#pragma mark - ConnectableDeviceDelegate

- (void)connectableDeviceDisconnected:(ConnectableDevice *)device 
                            withError:(NSError *)error {
    NSLog(@"Device disconnected: %@", device.friendlyName);
}

- (void)connectableDeviceReady:(ConnectableDevice *)device {
    NSLog(@"Device ready: %@", device.friendlyName);
    // Device is connected and ready to be used
}


// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
(const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeConnectionManagerSpecJSI>(params);
}
#endif


@end
