//
//  DeviceLocator.h
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


extern NSString *DeviceLocatorDidUpdateLocationNotificationName;
extern NSString *DeviceLocatorLocationKey;

typedef void(^DLLocationUpdateHandler)(CLLocation *location, NSError *error);

@protocol DeviceLocatorDelegate;

@interface DeviceLocator : NSObject <CLLocationManagerDelegate>

#pragma mark - Delegate

@property (nonatomic, assign) id<DeviceLocatorDelegate> delegate;

#pragma mark - Locating

- (void)start;
- (void)stop;

//
// If the receiver knows the current location, it will call the completion
// handler immediately with that value. Similar for errors. If, however, the
// receiver has not yet determined the current location, it will call the
// completion once the location has been determined.
//
- (void)currentLocationWithCompletionHandler:(DLLocationUpdateHandler)handler;

//
// If the receiver can not determine the current location within the provided
// timeout interval, an error is reported to the delegate and any completion
// handlers. Time is measured from when the receiver was last started via
// the -start method. The default value is the value of +defaultTimeoutInterval.
//
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

+ (NSTimeInterval)defaultTimeoutInterval;

#pragma mark - DeviceLocator is a singleton

+ (id)locator;

@end


@protocol DeviceLocatorDelegate <NSObject>

- (void)deviceLocator:(DeviceLocator *)locator
     didUpateLocation:(CLLocation *)location;
- (void)deviceLocatorDidTimeout:(DeviceLocator *)locator;
- (void)deviceLocator:(DeviceLocator *)locator
     didFailWithError:(NSError *)error;

@end
