//
//  DistanceFormatter.h
//  Lokalite
//
//  Created by John Debay on 8/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DistanceFormatter : NSObject

#pragma mark Instantiation and initialization

+ (id)formatter;

#pragma mark Converting distance values to strings

- (NSString *)distanceAsString:(CLLocationDistance)distance;

@end

