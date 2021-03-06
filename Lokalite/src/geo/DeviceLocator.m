//
//  DeviceLocator.m
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "DeviceLocator.h"


NSString *DeviceLocatorDidUpdateLocationNotificationName =
    @"DeviceLocatorDidUpdateLocationNotificationName";
NSString *DeviceLocatorLocationKey = @"DeviceLocatorLocationKey";

NSString *DeviceLocatorDidUpdateLocationErrorNotificationName =
    @"DeviceLocatorDidUpdateLocationErrorNotificationName";
NSString *DeviceLocatorLocationErrorKey = @"DeviceLocatorLocationErrorKey";


@interface NSError (DeviceLocatorHelpers)
+ (id)standardLocationTimeoutError;
@end


@interface DeviceLocator ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *lastLocation;
@property (nonatomic, retain) NSError *lastError;
@property (nonatomic, assign) BOOL didTimeout;

#pragma mark - Timeout

@property (nonatomic, retain) NSTimer *timeoutTimer;

- (void)startTimeoutTimer;
- (void)cancelTimeoutTimer;

#pragma mark - Location updates

- (void)processLocationUpdate:(CLLocation *)location;
- (void)processLocationUpdateFailure:(NSError *)error;

- (void)notifyLocationUpdateHandlersOfLocationUpdate:(CLLocation *)location
                                             orError:(NSError *)error
                                           orTimeout:(BOOL)didTimeout;
- (void)saveLocationUpdateHandler:(DLLocationUpdateHandler)handler;
- (void)forgetLocationUpdateHandler:(DLLocationUpdateHandler)handler;
- (void)forgetAllLocationUpdateHandlers;
- (void)broadcastNotificationForLocationUpdate:(CLLocation *)location;
- (void)broadcastNotificationForLocationUpdateError:(NSError *)error;

@property (nonatomic, retain) NSMutableSet *locationUpdateHandlers;

#pragma mark - Determining accuracy

- (BOOL)isValidLocation:(CLLocation *)location
            oldLocation:(CLLocation *)oldLocation;

- (CLLocationAccuracy)minimumAcceptableHorizontalAccuracy;
+ (NSTimeInterval)maximumAcceptableLocationAge;

@end


@implementation DeviceLocator

@synthesize delegate = delegate_;

@synthesize locationManager = locationManager_;
@synthesize lastLocation = lastLocation_;
@synthesize lastError = lastError_;
@synthesize didTimeout = didTimeout_;

@synthesize timeoutInterval = timeoutInterval_;
@synthesize timeoutTimer = timeoutTimer_;

@synthesize locationUpdateHandlers = locationUpdateHandlers_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [self stop];

    [locationManager_ release];
    [lastLocation_ release];
    [lastError_ release];

    [timeoutTimer_ release];

    [locationUpdateHandlers_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        locationUpdateHandlers_ = [[NSMutableSet alloc] init];
        timeoutInterval_ = [[self class] defaultTimeoutInterval];
        didTimeout_ = NO;
    }

    return self;
}

#pragma mark - Locating

- (void)start
{
    [[self locationManager] startUpdatingLocation];
    [self startTimeoutTimer];
}

- (void)stop
{
    [[self locationManager] stopUpdatingLocation];
    [self cancelTimeoutTimer];

    // HACK: -stop can be called as the result of a CLLocationManagerDelegate
    // method being fired, which causes a DeviceLocatorDelegate method to be
    // fired. This causes the location manager to be released while in its
    // own delegate method, which causes a crash. Avoid by autoreleasing and
    // setting to nil.
    [locationManager_ autorelease];
    locationManager_ = nil;
}

- (void)currentLocationWithCompletionHandler:(DLLocationUpdateHandler)handler
{
    CLLocation *location = [self lastLocation];
    NSError *error = [self lastError];
    BOOL didTimeout = [self didTimeout];

    if (location || error || didTimeout)
        handler(location, error, didTimeout);
    else
        [self saveLocationUpdateHandler:handler];
}

+ (NSTimeInterval)defaultTimeoutInterval
{

#if TARGET_IPHONE_SIMULATOR

    return 0.1;

#else

    NSBundle *bundle = [NSBundle mainBundle];
    NSNumber *n =
        [bundle objectForInfoDictionaryKey:@"LokaliteLocationTimeoutInterval"];

    return [n doubleValue];

#endif
}

#pragma mark - CLLocationManagerDelegate implementation

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if ([self isValidLocation:newLocation oldLocation:oldLocation]) {
        NSLog(@"Current location: %@", newLocation);
        [self processLocationUpdate:newLocation];
    } else
        NSLog(@"Ignoring location: %@", newLocation);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Failed to update location: %@", error);
    [self processLocationUpdateFailure:error];
}

#pragma mark - Timeout

- (void)startTimeoutTimer
{
    NSTimer *timer =
        [NSTimer scheduledTimerWithTimeInterval:[self timeoutInterval]
                                         target:self
                                       selector:@selector(timeoutTimerFired:)
                                       userInfo:nil
                                        repeats:NO];
    [self setTimeoutTimer:timer];
    [self setDidTimeout:NO];
}

- (void)cancelTimeoutTimer
{
    if ([self timeoutTimer]) {
        [[self timeoutTimer] invalidate];
        [self setTimeoutTimer:nil];
    }
}

- (void)timeoutTimerFired:(NSTimer *)timer
{
    [self setDidTimeout:YES];

    [self notifyLocationUpdateHandlersOfLocationUpdate:nil
                                               orError:nil
                                             orTimeout:[self didTimeout]];
    [self forgetAllLocationUpdateHandlers];

    [[self delegate] deviceLocatorDidTimeout:self];

    [self cancelTimeoutTimer];
}

#pragma mark - Location updates

- (void)processLocationUpdate:(CLLocation *)location
{
    [self setLastLocation:location];
    [self setLastError:nil];

    [self broadcastNotificationForLocationUpdate:location];

    [[self delegate] deviceLocator:self didUpateLocation:location];

    [self notifyLocationUpdateHandlersOfLocationUpdate:location
                                               orError:nil
                                             orTimeout:NO];
    [self forgetAllLocationUpdateHandlers];

    [self cancelTimeoutTimer];
}

- (void)processLocationUpdateFailure:(NSError *)error
{
    [self setLastLocation:nil];
    [self setLastError:error];

    [self broadcastNotificationForLocationUpdateError:error];

    [[self delegate] deviceLocator:self didFailWithError:error];

    [self notifyLocationUpdateHandlersOfLocationUpdate:nil
                                               orError:error
                                             orTimeout:NO];
    [self forgetAllLocationUpdateHandlers];

    [self cancelTimeoutTimer];
}

- (void)notifyLocationUpdateHandlersOfLocationUpdate:(CLLocation *)location
                                             orError:(NSError *)error
                                           orTimeout:(BOOL)didTimeout
{
    [[self locationUpdateHandlers]
     enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
         DLLocationUpdateHandler handler = (DLLocationUpdateHandler) obj;
         handler(location, error, didTimeout);
     }];
}

- (void)saveLocationUpdateHandler:(DLLocationUpdateHandler)handler
{
    [[self locationUpdateHandlers] addObject:[[handler copy] autorelease]];
}

- (void)forgetLocationUpdateHandler:(DLLocationUpdateHandler)handler
{
    [[self locationUpdateHandlers] removeObject:handler];
}

- (void)forgetAllLocationUpdateHandlers
{
    [[self locationUpdateHandlers] removeAllObjects];
}

- (void)broadcastNotificationForLocationUpdate:(CLLocation *)location
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:location
                                    forKey:DeviceLocatorLocationKey];

    [nc postNotificationName:DeviceLocatorDidUpdateLocationNotificationName
                      object:self
                    userInfo:userInfo];
}

- (void)broadcastNotificationForLocationUpdateError:(NSError *)error
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:error
                                    forKey:DeviceLocatorLocationErrorKey];

    [nc postNotificationName:DeviceLocatorDidUpdateLocationErrorNotificationName
                      object:self
                    userInfo:userInfo];
}

#pragma mark - Determining accuracy

- (BOOL)isValidLocation:(CLLocation *)location
            oldLocation:(CLLocation *)oldLocation
{
    NSTimeInterval age = [[location timestamp] timeIntervalSinceNow];
    BOOL current = abs(age) <= [[self class] maximumAcceptableLocationAge];

    BOOL sequential =
        [[location timestamp]
         timeIntervalSinceDate:[oldLocation timestamp]] >= 0;

    CLLocationAccuracy horizontalAccuracy = [location horizontalAccuracy];
    BOOL accurate = horizontalAccuracy >= 0;

    NSLog(@"New location is current: %@, sequential: %@, accurate: %@",
        current ? @"YES" : @"NO", sequential ? @"YES" : @"NO",
        accurate ? @"YES" : @"NO");

    return current && sequential && accurate;
}

+ (NSTimeInterval)maximumAcceptableLocationAge
{
    return 60;  // seconds
}

- (CLLocationAccuracy)minimumAcceptableHorizontalAccuracy
{

#if TARGET_IPHONE_SIMULATOR

    return 500;  // simulator has poor accuracy; always accept it

#else

    CLLocationAccuracy accuracy = [[self locationManager] desiredAccuracy];
    if (accuracy == kCLLocationAccuracyThreeKilometers)
        return 3000;
    else if (accuracy == kCLLocationAccuracyKilometer)
        return 1000;
    else if (accuracy == kCLLocationAccuracyNearestTenMeters)
        return 100;
    else
        return 100;  // we seem to get best accuracy of 80m often, so raising
                     // this threshold a bit

#endif

}

#pragma mark - Accessors

- (CLLocationManager *)locationManager
{
    if (!locationManager_) {
        locationManager_ = [[CLLocationManager alloc] init];
        [locationManager_ setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [locationManager_
         setPurpose:NSLocalizedString(@"devicelocator.purpose", nil)];
        [locationManager_ setDelegate:self];
    }

    return locationManager_;
}

#pragma mark - DeviceLocator is a singleton

+ (id)locator
{
    static DeviceLocator *locator = nil;
    if (!locator)
        locator = [[DeviceLocator alloc] init];

    return locator;
}

@end


@implementation NSError (DeviceLocatorHelpers)

+ (id)standardLocationTimeoutError
{
    NSString *message =
        NSLocalizedString(@"devicelocator.timeout.message", nil);
    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:message
                                    forKey:NSLocalizedDescriptionKey];

    return [NSError errorWithDomain:@"Lokalite"
                               code:100
                           userInfo:userInfo];
}

@end

