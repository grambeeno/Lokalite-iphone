//
//  DeviceLocator.h
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

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

#pragma mark - DeviceLocator is a singleton

+ (id)locator;

@end


@protocol DeviceLocatorDelegate <NSObject>

- (void)deviceLocator:(DeviceLocator *)locator
     didUpateLocation:(CLLocation *)location;
- (void)deviceLocator:(DeviceLocator *)locator
     didFailWithError:(NSError *)error;

@end
