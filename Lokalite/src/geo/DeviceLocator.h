//
//  DeviceLocator.h
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol DeviceLocatorDelegate;

@interface DeviceLocator : NSObject <CLLocationManagerDelegate>

@property (nonatomic, assign) id<DeviceLocatorDelegate> delegate;

#pragma mark - Locating

- (void)start;
- (void)stop;

@end


@protocol DeviceLocatorDelegate <NSObject>

- (void)deviceLocator:(DeviceLocator *)locator
     didUpateLocation:(CLLocation *)location;
- (void)deviceLocator:(DeviceLocator *)locator
     didFailWithError:(NSError *)error;

@end
