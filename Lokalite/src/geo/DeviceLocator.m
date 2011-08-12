//
//  DeviceLocator.m
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "DeviceLocator.h"


@interface NSError (DeviceLocatorHelpers)
+ (id)standardLocationTimeoutError;
@end


@interface DeviceLocator ()

@property (nonatomic, retain) CLLocationManager *locationManager;

#pragma mark - Timeout

@property (nonatomic, retain) NSTimer *timeoutTimer;

- (void)startTimeoutTimer;
- (void)cancelTimeoutTimer;

#pragma mark - Determining accuracy

- (BOOL)isValidLocation:(CLLocation *)location
            oldLocation:(CLLocation *)oldLocation;

- (CLLocationAccuracy)minimumAcceptableHorizontalAccuracy;
+ (NSTimeInterval)maximumAcceptableLocationAge;

@end


@implementation DeviceLocator

@synthesize delegate = delegate_;
@synthesize locationManager = locationManager_;
@synthesize timeoutTimer = timeoutTimer_;

- (void)dealloc
{
    delegate_ = nil;

    [self stop];
    [locationManager_ release];

    [timeoutTimer_ release];

    [super dealloc];
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
}

#pragma mark - CLLocationManagerDelegate implementation

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if ([self isValidLocation:newLocation oldLocation:oldLocation]) {
        NSLog(@"Current location: %@", newLocation);
        [[self delegate] deviceLocator:self didUpateLocation:newLocation];
    } else
        NSLog(@"Ignoring location: %@", newLocation);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Failed to update location: %@", error);
    [[self delegate] deviceLocator:self didFailWithError:error];
}

#pragma mark - Timeout

- (void)startTimeoutTimer
{
}

- (void)cancelTimeoutTimer
{
}

- (void)timeoutTimerFired
{
    NSError * error = [NSError standardLocationTimeoutError];
    [[self delegate] deviceLocator:self didFailWithError:error];
}

#pragma mark - Determining accuracy

- (BOOL)isValidLocation:(CLLocation *)location
            oldLocation:(CLLocation *)oldLocation
{
    NSTimeInterval age = [[location timestamp] timeIntervalSinceNow];
    BOOL current = abs(age) <= [[self class] maximumAcceptableLocationAge];

    BOOL sequential =
        [location.timestamp timeIntervalSinceDate:oldLocation.timestamp] >= 0;

    CLLocationAccuracy horizontalAccuracy = [location horizontalAccuracy];
    CLLocationAccuracy minAllowedHorizontalAccuracy =
        [self  minimumAcceptableHorizontalAccuracy];
    BOOL accurate =
        horizontalAccuracy >= 0 &&
        horizontalAccuracy <= minAllowedHorizontalAccuracy;

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

